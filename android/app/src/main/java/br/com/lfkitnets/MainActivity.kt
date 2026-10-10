package br.com.lfkitnets

import android.annotation.SuppressLint
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.webkit.JavascriptInterface
import android.webkit.WebChromeClient
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.Button
import android.widget.EditText
import androidx.activity.addCallback
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout

/**
 * Casca do LF Kitnets: abre o sistema que roda no computador de casa numa
 * WebView, com o mesmo layout do navegador do celular.
 */
class MainActivity : AppCompatActivity() {

    private lateinit var web: WebView
    private lateinit var atualizar: SwipeRefreshLayout
    private lateinit var erro: View
    private lateinit var campoEndereco: EditText

    // No site quem rola é o <main>, não a página; o JavaScript avisa quando ele
    // não está no topo, para "puxar para atualizar" não disparar no meio da rolagem.
    @Volatile private var conteudoRolado = false

    private val preferencias by lazy { getSharedPreferences("config", MODE_PRIVATE) }

    private var endereco: String
        get() = preferencias.getString("endereco", null) ?: getString(R.string.endereco_padrao)
        set(valor) = preferencias.edit().putString("endereco", valor).apply()

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        web = findViewById(R.id.web)
        atualizar = findViewById(R.id.atualizar)
        erro = findViewById(R.id.erro)
        campoEndereco = findViewById(R.id.endereco)

        // Android 15 desenha atrás das barras do sistema; o conteúdo fica abaixo delas.
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.raiz)) { view, insets ->
            val barras = insets.getInsets(WindowInsetsCompat.Type.systemBars() or WindowInsetsCompat.Type.ime())
            view.setPadding(barras.left, barras.top, barras.right, barras.bottom)
            WindowInsetsCompat.CONSUMED
        }

        web.settings.javaScriptEnabled = true
        web.settings.domStorageEnabled = true
        web.addJavascriptInterface(Ponte(), "LFKitnets")
        web.webChromeClient = WebChromeClient() // mostra os confirm() do site ("Tem certeza?")
        web.webViewClient = Navegacao()

        atualizar.setColorSchemeResources(R.color.indigo)
        atualizar.setOnChildScrollUpCallback { _, _ -> conteudoRolado || web.canScrollVertically(-1) }
        atualizar.setOnRefreshListener { web.reload() }

        onBackPressedDispatcher.addCallback(this) {
            if (erro.visibility != View.VISIBLE && web.canGoBack()) web.goBack() else finish()
        }

        findViewById<Button>(R.id.tentar).setOnClickListener {
            val digitado = campoEndereco.text.toString().trim().trimEnd('/')
            if (digitado.isNotEmpty()) endereco = if (digitado.startsWith("http")) digitado else "http://$digitado"
            carregar()
        }

        if (savedInstanceState == null) carregar() else web.restoreState(savedInstanceState)
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        web.saveState(outState)
    }

    private fun carregar() {
        erro.visibility = View.GONE
        atualizar.visibility = View.VISIBLE
        web.loadUrl(endereco)
    }

    private fun mostrarErro() {
        atualizar.isRefreshing = false
        atualizar.visibility = View.GONE
        campoEndereco.setText(endereco)
        erro.visibility = View.VISIBLE
    }

    private inner class Navegacao : WebViewClient() {
        // Páginas do próprio sistema abrem no app; links de fora, no navegador.
        override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
            val destino = request.url
            if (destino.host == Uri.parse(endereco).host) return false
            startActivity(Intent(Intent.ACTION_VIEW, destino))
            return true
        }

        override fun onPageFinished(view: WebView, url: String) {
            atualizar.isRefreshing = false
            view.evaluateJavascript(JS_ROLAGEM, null)
        }

        override fun onReceivedError(view: WebView, request: WebResourceRequest, error: WebResourceError) {
            if (request.isForMainFrame) mostrarErro()
        }
    }

    private inner class Ponte {
        @JavascriptInterface
        fun rolado(valor: Boolean) {
            conteudoRolado = valor
        }
    }

    private companion object {
        // Escuta a rolagem de qualquer elemento (fase de captura) e zera ao trocar
        // de página pelo Turbo, que não recarrega o documento.
        const val JS_ROLAGEM = """
            (function () {
              if (window.__lfkitnets) return;
              window.__lfkitnets = true;
              document.addEventListener('scroll', function (e) {
                var alvo = e.target === document ? document.scrollingElement : e.target;
                LFKitnets.rolado(alvo.scrollTop > 0);
              }, true);
              document.addEventListener('turbo:load', function () { LFKitnets.rolado(false); });
            })();
        """
    }
}
