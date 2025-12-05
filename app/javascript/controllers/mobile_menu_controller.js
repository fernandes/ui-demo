import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "openIcon", "closeIcon", "menuText"]

  connect() {
    this.isOpen = false
  }

  toggle() {
    this.isOpen ? this.close() : this.open()
  }

  open() {
    this.isOpen = true
    this.panelTarget.classList.remove("hidden")
    // Trigger reflow for animation
    this.panelTarget.offsetHeight
    this.panelTarget.classList.add("animate-in", "fade-in-0")

    // Toggle hamburger to X
    this.openIconTarget.classList.add("hidden")
    this.closeIconTarget.classList.remove("hidden")

    // Change menu text to "Menu"
    this.menuTextTarget.textContent = "Menu"

    // Prevent body scroll
    document.body.style.overflow = "hidden"
  }

  close() {
    this.isOpen = false
    this.panelTarget.classList.add("hidden")
    this.panelTarget.classList.remove("animate-in", "fade-in-0")

    // Toggle X to hamburger
    this.openIconTarget.classList.remove("hidden")
    this.closeIconTarget.classList.add("hidden")

    // Restore menu text
    this.menuTextTarget.textContent = "Menu"

    // Restore body scroll
    document.body.style.overflow = ""
  }

  // Close menu when clicking a link
  navigate() {
    this.close()
  }

  // Close on escape key
  closeOnEscape(event) {
    if (event.key === "Escape" && this.isOpen) {
      this.close()
    }
  }
}
