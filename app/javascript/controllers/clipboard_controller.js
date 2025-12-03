import { Controller } from "@hotwired/stimulus"

// Copy to clipboard controller for code blocks.
export default class extends Controller {
  static targets = ["icon"]
  static values = {
    content: String
  }

  async copy() {
    try {
      await navigator.clipboard.writeText(this.contentValue)
      this.showSuccess()
    } catch (err) {
      console.error("Failed to copy:", err)
      this.showError()
    }
  }

  showSuccess() {
    // Temporarily change icon to checkmark
    if (this.hasIconTarget) {
      const icon = this.iconTarget
      const originalHTML = icon.innerHTML

      icon.innerHTML = `
        <polyline points="20 6 9 17 4 12"></polyline>
      `
      icon.classList.add("text-green-500")

      setTimeout(() => {
        icon.innerHTML = originalHTML
        icon.classList.remove("text-green-500")
      }, 2000)
    }
  }

  showError() {
    if (this.hasIconTarget) {
      this.iconTarget.classList.add("text-red-500")
      setTimeout(() => {
        this.iconTarget.classList.remove("text-red-500")
      }, 2000)
    }
  }
}
