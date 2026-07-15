import { Controller } from "@hotwired/stimulus"

// Toggles the mobile sidebar drawer + backdrop.
export default class extends Controller {
  static targets = ["panel", "overlay"]

  toggle() {
    this.panelTarget.classList.toggle("-translate-x-full")
    this.overlayTarget.classList.toggle("hidden")
  }

  close() {
    this.panelTarget.classList.add("-translate-x-full")
    this.overlayTarget.classList.add("hidden")
  }
}
