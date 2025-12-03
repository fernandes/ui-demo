import { Controller } from "@hotwired/stimulus"

// TOC controller for dynamic example links and scroll spy
export default class extends Controller {
  static targets = ["link", "examplesContainer"]

  connect() {
    this.populateExamples()
    this.setupScrollSpy()
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  populateExamples() {
    if (!this.hasExamplesContainerTarget) return

    // Find all example sections on the page
    const examples = document.querySelectorAll("[data-example]")

    examples.forEach(example => {
      const name = example.dataset.example
      const id = example.id || `example-${name}`
      const title = example.querySelector("h3")?.textContent || name.replace(/-/g, " ")

      const link = document.createElement("a")
      link.href = `#${id}`
      link.className = "text-muted-foreground hover:text-foreground text-[0.8rem] no-underline transition-colors"
      link.textContent = title
      link.dataset.tocTarget = "link"

      this.examplesContainerTarget.appendChild(link)
    })
  }

  setupScrollSpy() {
    const options = {
      root: null,
      rootMargin: "-80px 0px -80% 0px",
      threshold: 0
    }

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.setActiveLink(entry.target.id)
        }
      })
    }, options)

    // Observe all sections with IDs
    document.querySelectorAll("[id]").forEach(section => {
      if (section.id && !section.id.startsWith("radix")) {
        this.observer.observe(section)
      }
    })
  }

  setActiveLink(id) {
    this.linkTargets.forEach(link => {
      const href = link.getAttribute("href")
      const isActive = href === `#${id}`
      link.dataset.active = isActive
    })
  }
}
