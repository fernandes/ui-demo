import { Controller } from "@hotwired/stimulus"

// Manages code format preference across all examples on the page.
// Syncs tabs between all examples and persists preference in cookie.
// Works with UI::Tabs component by intercepting tab clicks and syncing state.
export default class extends Controller {
  static values = {
    default: { type: String, default: "erb" }
  }

  connect() {
    this.format = this.getPreference()

    // Find the tabs controller element within this example
    this.tabsElement = this.element.querySelector("[data-controller*='ui--tabs']")

    if (this.tabsElement) {
      // Override the default value to use saved preference
      this.syncToSavedPreference()

      // Listen for tab clicks to capture format changes
      this.tabsElement.addEventListener("click", this.handleTabClick.bind(this))
    }

    // Listen for global format change events from other examples
    document.addEventListener("code-format:change", this.handleGlobalChange.bind(this))
  }

  disconnect() {
    document.removeEventListener("code-format:change", this.handleGlobalChange.bind(this))
    if (this.tabsElement) {
      this.tabsElement.removeEventListener("click", this.handleTabClick.bind(this))
    }
  }

  handleTabClick(event) {
    // Find if clicked element is a tab trigger
    const trigger = event.target.closest("[data-ui--tabs-target='trigger']")
    if (!trigger) return

    const value = trigger.dataset.value
    if (!value) return

    // Extract format from prefixed value (e.g., "default-erb" -> "erb")
    const format = this.extractFormat(value)
    if (!format || format === this.format) return

    this.format = format
    this.setPreference(format)

    // Notify other instances
    document.dispatchEvent(
      new CustomEvent("code-format:change", {
        detail: { format, source: this.element }
      })
    )
  }

  // Extract format suffix from prefixed tab value
  extractFormat(value) {
    // Match known formats at the end of the value
    const formats = ["erb", "phlex", "view_component"]
    for (const format of formats) {
      if (value.endsWith(`-${format}`)) {
        return format
      }
    }
    return value
  }

  handleGlobalChange(event) {
    // Skip if this is the source of the event
    if (event.detail.source === this.element) return

    this.format = event.detail.format
    this.syncTabs()
  }

  syncToSavedPreference() {
    // Wait for tabs controller to initialize, then sync
    requestAnimationFrame(() => {
      this.syncTabs()
    })
  }

  syncTabs() {
    if (!this.tabsElement) return

    const triggers = this.tabsElement.querySelectorAll("[data-ui--tabs-target='trigger']")
    const contents = this.tabsElement.querySelectorAll("[data-ui--tabs-target='content']")

    // Find and click the trigger matching our format
    triggers.forEach(trigger => {
      const value = trigger.dataset.value
      const triggerFormat = this.extractFormat(value)
      const isActive = triggerFormat === this.format

      if (isActive) {
        // Update trigger state
        trigger.setAttribute("data-state", "active")
        trigger.setAttribute("aria-selected", "true")
        trigger.setAttribute("tabindex", "0")
      } else {
        trigger.setAttribute("data-state", "inactive")
        trigger.setAttribute("aria-selected", "false")
        trigger.setAttribute("tabindex", "-1")
      }
    })

    // Update content visibility
    contents.forEach(content => {
      const value = content.dataset.value
      const contentFormat = this.extractFormat(value)
      const isActive = contentFormat === this.format

      if (isActive) {
        content.setAttribute("data-state", "active")
        content.removeAttribute("hidden")
      } else {
        content.setAttribute("data-state", "inactive")
        content.setAttribute("hidden", "")
      }
    })
  }

  getPreference() {
    const cookie = document.cookie
      .split("; ")
      .find(row => row.startsWith("code_format="))

    if (cookie) {
      return cookie.split("=")[1]
    }

    return this.defaultValue
  }

  setPreference(format) {
    // Set cookie for 1 year
    const expires = new Date()
    expires.setFullYear(expires.getFullYear() + 1)
    document.cookie = `code_format=${format}; expires=${expires.toUTCString()}; path=/; SameSite=Lax`
  }
}
