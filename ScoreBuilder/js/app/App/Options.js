'use strict';

const OPTIONS_DIVERSES =  ['barres', 'keep']

class Options extends Panneau {

  static prepare(){

    this.close()
    this.watch()

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
    // console.log("-> Options.setValues avec", values)
    OPTIONS_DIVERSES.forEach( key => {
      let cb = DGet(`#option_${key}`)
      cb.checked = values[key]
    })
    let tuneMode, tuneNote, tuneAlte, tune = values.tune
    // console.log("tune = ", tune)
    if ( tune ) {
      tuneNote = tune.substr(0,1).toUpperCase()
      tuneAlte = tune.substr(1,1)
      if ( tuneAlte == 'm') {
        tuneMode = String(tuneAlte)
        tuneAlte = ""
      } else {
        tuneMode = tune.substr(2,1)
      }
      // console.log("Tune = ", tuneNote, tuneAlte, tuneMode)
      DGet('#option_tune-note').value = tuneNote
      DGet('#option_tune-alte').value = tuneAlte
      DGet('#option_tune-mode').value = tuneMode
    }

    const time = values.time
    if ( time ) {
      DGet('#option_time-deno').value = time.substr(0,1)
      DGet('#option_time-divi').value = time.substr(2,1)
    }

    // - Format papier - (p.e. a4 ou lettre)
    const format = values.format || 'a0'
    DGet('#option_format').value = format

    const system = values.system
    if ( system ) {
      DGet('#option_systeme').value = system
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
