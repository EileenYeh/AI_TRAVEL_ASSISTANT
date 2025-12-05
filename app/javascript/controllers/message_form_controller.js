// app/javascript/controllers/message_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "form"]

  connect() {
    if (this.hasTextareaTarget) {
      this.textareaTarget.addEventListener('keydown', this.handleKeydown.bind(this))
    }
  }

  disconnect() {
    if (this.hasTextareaTarget) {
      this.textareaTarget.removeEventListener('keydown', this.handleKeydown)
    }
  }

  handleKeydown(event) {
    // Enter键发送（非Ctrl/Shift）
    if (event.key === 'Enter' && !event.ctrlKey && !event.shiftKey) {
      event.preventDefault()
      this.submitForm()
    }

    // Ctrl+Enter 换行
    if (event.key === 'Enter' && event.ctrlKey) {
      // 允许默认行为（换行）
      // 不需要 preventDefault
    }
  }

  submitForm() {
    if (this.hasFormTarget) {
      this.formTarget.requestSubmit()
    } else {
      const form = this.element.closest('form')
      if (form) form.requestSubmit()
    }
  }

  // 可选：清空表单
  clear() {
    if (this.hasTextareaTarget) {
      this.textareaTarget.value = ''
      this.textareaTarget.style.height = 'auto'
    }
  }
}
