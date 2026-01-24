import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.toggle()
  }

  toggle() {
    const percentageRadio = this.element.querySelector('input[value="percentage"]')
    const prohibitionRadio = this.element.querySelector('input[value="prohibition"]')
    const percentageFields = this.element.querySelector('#percentage-fields')
    const prohibitionMessage = this.element.querySelector('#prohibition-message')

    if (percentageRadio && percentageRadio.checked) {
      if (percentageFields) percentageFields.classList.remove('hidden')
      if (prohibitionMessage) prohibitionMessage.classList.add('hidden')
    } else if (prohibitionRadio && prohibitionRadio.checked) {
      if (percentageFields) percentageFields.classList.add('hidden')
      if (prohibitionMessage) prohibitionMessage.classList.remove('hidden')
    }
  }
}