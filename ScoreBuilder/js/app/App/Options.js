'use strict';

const OPTIONS_DIVERSES =  ['barres', 'keep']

class Options extends Panneau {

  static prepare(){

    this.close()
    this.watch()
    this.observe()

  }

  static observe(){
    // Pour gérer les espacements entre les systèmes
    listen(this.cbSVSpaceSystems,'click', this.onClickCBvSpaceSystems.bind(this))
    listen(this.vSpaceSystemsField,'focus', _ => {this.vSpaceSystemsField.select()} )
    listen(this.cbStavesVSpace,'click', this.onClickCBstavesVSpace.bind(this))
    listen(this.stavesVSpaceField,'focus', _ => {this.stavesVSpaceField.select()} )
  }

  static onClickCBvSpaceSystems(ev){
    const enable = this.cbSVSpaceSystems.checked
    this.vSpaceSystemsField.disabled = !enable
    if ( enable ) { this.vSpaceSystemsField.focus() }
    return true
  }

  static onClickCBstavesVSpace(ev){
    const enable = this.cbStavesVSpace.checked
    this.stavesVSpaceField.disabled = !enable
    if ( enable ) { this.stavesVSpaceField.focus() }
    return true
  }

  static get vSpaceSystemsField(){
    return this._vspacesysfield || (this._vspacesysfield = DGet('input#systems-vspace'))
  }
  static get cbSVSpaceSystems(){
    return this._cbvspacesys ||= (this._cbvspacesys = DGet('input#cb-systems-vspace'))
  }

  static get stavesVSpaceField(){
    return this._vspacestavesfield || (this._vspacestavesfield = DGet('input#staves-vspace'))
  }
  static get cbStavesVSpace(){
    return this._cbvspacestaves ||= (this._cbvspacestaves = DGet('input#cb-staves-vspace'))
  }

  static getValues(){
    let data = []
    // - Format papier - (p.e. a4 ou lettre)
    const format = DGet('#option_format').value
    data.push(`--page ${format}`)
    // - Système -
    let system = DGet('#option_systeme').value
    if ( system == "---"){
      // Ne rien mettre
    } else if ( isNaN(system) ) {
      data.push(`--${system}`)
    } else {
      const contStaves = DGet('#container-systemes')
      const keys  = []
      const names = []
      contStaves.querySelectorAll('div.staff').forEach( divstaff => {
        const key   = divstaff.querySelector('.staff-cle').value
        const name  = divstaff.querySelector('.staff-name').value
        keys.push(key)
        names.push(name)
      })
      data.push(`--staves ${keys.length}`)
      data.push(`--staves_keys ${keys.join(',')}`)
      data.push(`--staves_names ${names.join(',')}`)
    }
    // - Diverses Options -
    OPTIONS_DIVERSES.forEach( key => {
      DGet(`#option_${key}`).checked && data.push(`--${key}`)
    })
    // - Espacement entre les systèmes -
    if ( this.cbSVSpaceSystems.checked ) {
      const vspace = Number(this.vSpaceSystemsField.value)
      if ( isNaN(vspace) ) vspace = 9
      data.push(`--systems_vspace ${vspace}`)
    }
    // - Espacement entre les portées -
    if ( this.cbStavesVSpace.checked ) {
      const vspace = Number(this.stavesVSpaceField.value)
      if ( isNaN(vspace) ) vspace = 9
      data.push(`--staves_vspace ${vspace}`)
    }
    // - Tune -
    let tuneNote = DGet('#option_tune-note').value
    let tuneAlte = DGet('#option_tune-alte').value
    let tuneMode = DGet('#option_tune-mode').value
    data.push(`--tune ${tuneNote}${tuneAlte}${tuneMode}`)
    // - Time -
    let timeDeno = DGet('#option_time-deno').value
    let timeDivi = DGet('#option_time-divi').value
    data.push(`--time ${timeDeno}/${timeDivi}`)

    return data.join("\n")
  }

  static setValues(values){
    console.log("-> Options.setValues avec", values)
    OPTIONS_DIVERSES.forEach( key => {
      let cb = DGet(`#option_${key}`)
      cb.checked = values[key]
    })
    // - Tonalité -
    let tuneMode, tuneNote, tuneAlte, tune = values.tune
    if ( tune ) {
      tuneNote = tune.substr(0,1).toUpperCase()
      tuneAlte = tune.substr(1,1)
      if ( tuneAlte == 'm') {
        tuneMode = String(tuneAlte)
        tuneAlte = ""
      } else {
        tuneMode = tune.substr(2,1)
      }
      DGet('#option_tune-note').value = tuneNote
      DGet('#option_tune-alte').value = tuneAlte
      DGet('#option_tune-mode').value = tuneMode
    }

    // - Métrique -
    const time = values.time
    if ( time ) {
      DGet('#option_time-deno').value = time.substr(0,1)
      DGet('#option_time-divi').value = time.substr(2,1)
    }

    // - Format papier - (p.e. a4 ou lettre)
    const format = values.page || 'a0'
    DGet('#option_format').value = format

    const system = values.system
    if ( system ) {
      DGet('#option_systeme').value = system
    }

    // - Espacement entre les systèmes -
    const vSpaceIsDefined = values.systems_vspace
    this.cbSVSpaceSystems.checked = vSpaceIsDefined
    if ( vSpaceIsDefined ) {
      this.vSpaceSystemsField.value = values.systems_vspace
    }
    // - Espacement entre les portées -
    const stavesVSpaceIsDefined = values.staves_vspace
    this.cbStavesVSpace.checked = stavesVSpaceIsDefined
    if ( stavesVSpaceIsDefined ) {
      this.stavesVSpaceField.value = values.staves_vspace
    }

  }

  static extractOptionsFrom(musCode){
    // console.log("-> extractOptionsFrom avec : ", musCode)
    const notOptions = []
    const options = {}
    musCode.split("\n").forEach( line => {
      if ( line.substr(0,2) == '--' ) {
        let line_option = line.substr(2).trim()
        let [option, value] = line_option.split(' ')
        switch(option){
        case 'piano':case 'quatuor':
          value  = String(option)
          option = 'system'
          break
        default:
          value || (value = true)
          if ( value == 'OFF' ) value = false
        }
        Object.assign(options, {[option]: value})
      } else {
        notOptions.push(line)
      }
    })
    return [notOptions.join("\n"), options]
  }

  static get btnClose(){
    return this._btnclose || (this._btnclose = DGet('.btn-close', this.panneau))
  }
  static get panneau(){
    return this._panneau || (this._panneau = DGet('#panneau-options'))
  }
}
