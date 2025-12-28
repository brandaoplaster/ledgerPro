import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("NumberInput controller connected!", this.element)
  }

  keydown(event) {
    const key = event.key
    console.log("Key pressed:", key)

    const allowedKeys = ['Backspace', 'Delete', 'Tab', 'Escape', 'Enter', 'Home', 'End',
      'ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown']

    if (allowedKeys.includes(key)) {
      return
    }

    if (event.ctrlKey || event.metaKey) {
      return
    }

    if (!/^[0-9.,]$/.test(key)) {
      console.log("Blocking key:", key)
      event.preventDefault()
      return
    }

    const input = event.target
    const value = input.value
    if ((key === '.' || key === ',') && (value.includes('.') || value.includes(','))) {
      event.preventDefault()
    }
  }

  validate(event) {
    console.log("validate() called", event)
    const input = event.target
    const cursorPosition = input.selectionStart
    let value = input.value
    const originalLength = value.length

    value = value.replace(/[^0-9.,]/g, '')

    value = value.replace(/,/g, '.')

    const parts = value.split('.')
    if (parts.length > 2) {
      value = parts[0] + '.' + parts.slice(1).join('')
    }

    if (value !== input.value) {
      input.value = value

      const newLength = value.length
      const cursorOffset = newLength - originalLength
      const newPosition = Math.max(0, cursorPosition + cursorOffset)
      input.setSelectionRange(newPosition, newPosition)
    }
  }

  blur(event) {
    const input = event.target
    let value = input.value

    if (value.length > 1 && value[0] === '0' && value[1] !== '.') {
      value = value.replace(/^0+/, '') || '0'
    }

    if (value[0] === '.') {
      value = '0' + value
    }

    if (value.endsWith('.')) {
      value = value.slice(0, -1)
    }

    input.value = value
  }
}
