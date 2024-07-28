'use strict';

// const OPTIONS_DIVERSES =  ['barres', 'keep', 'page_numbers', 'mesure_numbers','number_per_5','measure_number_under_staff']
const DATA_OPTIONS = {
    barres:         {name: "Barres de mesure", default: true}
  , keep:           {name: "Garder le fichier .ly", default: false}
  , page_numbers:   {name: "Afficher les numéros de page", default: true, when_true: 'arabic', when_false: 'OFF'}
  , mesure_numbers: {name: "Afficher les numéros de mesure", default: true, when_false: 'OFF'}
  , number_per_5:   {name: "Numéroter de 5 en 5", default: false, depends_on: 'mesure_numbers'}
  , measure_number_under_staff: {name:"Numéro de mesure sous la portée", depends_on: 'mesure_numbers', default: false}
}
const OPTIONS_DIVERSES = Object.keys(DATA_OPTIONS)
// console.log("OPTIONS_DIVERSES:", OPTIONS_DIVERSES)

const CBS = {}
const CBS_WITH_DEPENDENCES = {}


class Options extends Panneau {

  static prepare(){

    this.close()
    this.watch()
    this.buildCbsOptions()
    this.buildSystemCountMenus()
    this.buildStaffSizeMenu()
    this.observe()

  }

  static buildSystemCountMenus(){
    let i, opt;
    document.querySelectorAll('select.system-count').forEach(menu =>{
      opt = DCreate('OPTION', {value:'-', text:'-'})
      menu.appendChild(opt)
      for(i = 1; i < 20; ++i){
        opt = DCreate('OPTION', {value:String(i), text:String(i)})
        menu.appendChild(opt)
      }
    })
  }
  static buildStaffSizeMenu(){
    let i, tit, opt;
    opt = DCreate('OPTION', {value:'-', text:'-'})
    this.menuStaffSize.appendChild(opt)
    for(i = 10; i < 40; ++i){
      tit = i != 20 ? String(i) : "20 (défaut)"
      opt = DCreate('OPTION', {value:String(i), text:String(i)})
      this.menuStaffSize.appendChild(opt)
    }
  }

  static buildCbsOptions(){
    const container = DGet('fieldset#options-diverses div.container')
    OPTIONS_DIVERSES.forEach( koption => {
      const doption = DATA_OPTIONS[koption]
      const div = DCreate('DIV')
      const ido = `option_${koption}`
      const cb  = DCreate('INPUT',{type:'checkbox', id:ido, checked: doption.default})
      Object.assign(CBS, {[koption]: cb})
      div.appendChild(cb)
      const lab = DCreate('LABEL',{for: ido, text: doption.name})
      div.appendChild(lab)
      container.appendChild(div)
      if ( doption.depends_on ) {
        // L’option dépend d’une autre. C’est-à-dire que si l’autre
        // n’est pas checkée, alors celle-ci n’est pas accessible
        if ( undefined == CBS_WITH_DEPENDENCES[doption.depends_on]){
          Object.assign(CBS_WITH_DEPENDENCES, { [doption.depends_on]: {
              obj: CBS[doption.depends_on]
            , dependences: []
          }})
        }
        CBS_WITH_DEPENDENCES[doption.depends_on].dependences.push(cb)
      }
    })
    // Toutes les CB avec dépendences doivent générer cette dépendences
    Object.keys(CBS_WITH_DEPENDENCES).forEach( cb_id => {
      const data_cb = CBS_WITH_DEPENDENCES[cb_id]
      const cb_obj  = data_cb.obj
      listen(cb_obj,'click',this.onClickCbDependence.bind(this, cb_obj, data_cb.dependences))
    })
  }

  static onClickCbDependence(cb, dependences, ev){
    dependences.forEach( dependence => {
      dependence.disabled = !cb.checked
    })
    return true
  }

  static observe(){
    // Quand on change de système, il faut peut-être construire les
    // portées
    listen(this.menuSystems, 'change', this.onChangeSystem.bind(this))
    // Pour gérer les espacements entre les systèmes
    listen(this.cbSVSpaceSystems,'click', this.onClickCBvSpaceSystems.bind(this))
    listen(this.vSpaceSystemsField,'focus', _ => {this.vSpaceSystemsField.select()} )
    listen(this.cbStavesVSpace,'click', this.onClickCBstavesVSpace.bind(this))
    listen(this.stavesVSpaceField,'focus', _ => {this.stavesVSpaceField.select()} )
  
    // Pour générer une alerte quand on choisit un nombre de systèmes
    // différent pour la première page (ça n’est pas encore possible)
    listen(this.menuSystemCountFirstPage,'change', this.onChangeNombreSystems.bind(this, true))
    listen(this.menuSystemCount,'change', this.onChangeNombreSystems.bind(this, false))

    // La fenêtre doit être déplaçable
    $(this.panneau).draggable()

  }

  /* Méthode appelée quand on définit le nombre de systèmes
     (pour le moment, on ne peut pas mettre un nombre de systèmes
      différent pour la première page => on synchronise les deux 
      valeurs) 
    @param m1rePage [Boolean] Est à true quand la méthode est appelée
                    par le menu du nombre pour la première page
  */
  static onChangeNombreSystems(ev, m1rePage){
    if ( m1rePage ) {
      this.menuSystemCount.value = this.menuSystemCountFirstPage.value
    } else {
      this.menuSystemCountFirstPage.value = this.menuSystemCount.value
    }
    message("Il n’est pas encore possible d’attribuer un nombre de systèmes différent à la 1<sup>re</sup> page.")
    return stopEvent(ev)
  }

  /**
  * Méthode appelée quand on change de système
  */
  static onChangeSystem(ev){
    const value = this.menuSystems.value
    // On masque toujours le conteneur des partitions personnalisées,
    // il sera rouvert par #buildOptionsStavesFrom si nécessaire
    this.stavesContainer.classList.add('hidden')
    if ( !isNaN(value) ) {
      const aryKeys = new Array(Number(value))
      aryKeys[0] = 'F'
      this.buildOptionsStavesFrom({staves:value, staves_keys:aryKeys})
    }
    return true
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
    return this._cbvspacesys || (this._cbvspacesys = DGet('input#cb-systems-vspace'))
  }

  static get stavesVSpaceField(){
    return this._vspacestavesfield || (this._vspacestavesfield = DGet('input#staves-vspace'))
  }
  static get cbStavesVSpace(){
    return this._cbvspacestaves || (this._cbvspacestaves = DGet('input#cb-staves-vspace'))
  }

  static get menuSystemCountFirstPage(){
    return this._menusyscountpage1 || (this._menusyscountpage1 = DGet('select#system-count-first-page'))
  }
  static get menuSystemCount(){
    return this._menusyscount || (this._menusyscount = DGet('select#system-count-per-page'))
  }

  static get menuSystems(){
    return this._menusystem || (this._menusystem = DGet('#option_systeme'))
  }
  static get menuStaffSize(){
    return this._menustaffsize || (this._menustaffsize = DGet('select#staff_size'))
  }

  static getValues(){
    let data = []
    // - Format papier - (p.e. a4 ou lettre)
    const format = DGet('#option_format').value
    data.push(`--page ${format}`)
    // - Système -
    let system = this.menuSystems.value
    if ( system == "---"){
      // Ne rien mettre
    } else if ( isNaN(system) ) {
      data.push(`--${system}`)
    } else {
      let keys  = [], names = [];
      this.stavesContainer
        .querySelectorAll('div.staff')
        .forEach( divstaff => {
          const key   = divstaff.querySelector('.staff-cle').value
          const name  = divstaff.querySelector('.staff-name').value
          keys.push(key)
          names.push(name)
        })
      keys  = keys.reverse()
      names = names.reverse()

      // Lire plus bas la note : NOTE GROUPED NAMES
      names = this.inverseGroupeStaffNames(names)
      data.push(`--staves ${keys.length}`)
      data.push(`--staves_keys ${keys.join(',')}`)
      data.push(`--staves_names ${names.join(',')}`)
    }
    // - Nombre de systèmes par page -
    const sysCountP1 = this.menuSystemCountFirstPage.value
    if ( sysCountP1 != '-' ) {
      data.push(`--system_count_first_page ${sysCountP1}`)
    }
    const systemCount = this.menuSystemCount.value
    if ( systemCount != '-'){
      data.push(`--system_count ${systemCount}`)
    }
    // - Taille de portée -
    const staffSize = Number(this.menuStaffSize.value)
    if ( staffSize != 20 && staffSize != '-') {
      data.push(`--staff_size ${staffSize}`)
    }
    // - Diverses Options -
    OPTIONS_DIVERSES.forEach( key => {
      const doption = DATA_OPTIONS[key]
      const checked = DGet(`#option_${key}`).checked
      let value = `--${key}`
      if ( !checked && doption.when_false) {
        value = `${value} ${doption.when_false}`
      } else if ( checked && doption.when_true ) {
        value = `${value} ${doption.when_true}`
      } else if ( !checked ) {
        value = null
      }
      value && data.push(value)
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

  /**
  * Pour placer toutes les valeurs d’option dans le formulaire
  * 
  * @rappel
  *   Les valeurs d’options sont toutes les valeurs définies par
  *   ’--<clé option>’ dans le fichier MUS.
  */
  static setValues(values){
    // console.log("-> Options.setValues avec", values)
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
      this.menuSystems.value = system
    }
    if ( values.staves ) {
      // <= Le nombre de portée est défini explicitement
      // => Il faut mettre les portées
      this.buildOptionsStavesFrom(values)
    } else {
      this.stavesContainer.classList.add('hidden')
    }
    // - Nombre de systèmes par page -
    const systemCount = values.system_count || '-'
    const sysCountP1  = values.system_count_first_page || '-'
    this.menuSystemCount.value          = systemCount
    this.menuSystemCountFirstPage.value = sysCountP1

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
    // - Taille de portée -
    if ( values.staff_size ) {
      this.menuStaffSize.value = values.staff_size
    }
  }

  /**
  * Méthode appelée par setValues pour définir les portées lorsque
  * elles sont explicites
  * 
  * @param [Hash] values
  *   values.staves_keys  : liste des clés (de bas en haut)
  *   values.staves_names : liste des noms des portées (id)
  */
  static buildOptionsStavesFrom(values){
    const keys  = (values.staves_keys  || []).reverse()
    let names = (values.staves_names || []).reverse()
    // Lire ci-dessous la note NOTE GROUPED NAMES
    console.log("Names dans fichier : ", names.join(', '))
    names = this.inverseGroupeStaffNames(names)
    console.log("Names après inversion : ", names.join(', '))
    this.menuSystems.value = String(values.staves)
    this.stavesContainer.innerHTML = ""
    this.stavesContainer.classList.remove('hidden')
    // for(var istaff=Number(values.staves); istaff > 0; --istaff){
    for(var istaff=0,max=Number(values.staves);istaff < max;++istaff){
      const idx = Number(istaff)
      this.buildNewStaffLine(max-istaff,keys[idx],names[idx])
    }    
  }
  /**
  * Méthode qui ajoute une ligne pour une nouvelle portée
  * 
  * La méthode est utilisée lorsqu’on choisit un nombre de portée
  * au lieu d’un système précis, ainsi qu’au chargement d’une parti-
  * tion lorsque les portées sont définies précisément.
  * 
  */
  static buildNewStaffLine(staffIndex, staffKey, staffName){
    const div = DCreate('DIV',{class:'staff'})
    const inputName = DCreate('INPUT',{value:(staffName||''), type:'text', class:'staff-name staff-value', placeholder:"Nom aff."})
    div.appendChild(DCreate('SPAN', {text: `Staff ${staffIndex} : `, class:"staff-index label"}))
    div.appendChild(this.buildMenuKeys(staffKey))
    div.appendChild(inputName)
    this.stavesContainer.appendChild(div)
  }

  /**
   * NOTE GROUPED NAMES
  * À cause de la disposition et de l’écriture de bas en haut,
  * les groupements à l’aide des {...} et des [...] sont mal
  * répartis. Il faut les inverser :
  #     ’{instrument’   -> ’instrument}’
  #     ’,instrument}’  -> ’{instrument’
  # idem avec les crochets
  */
  static inverseGroupeStaffNames(names){
    const wf_names = []
    names.forEach( name => {
      name = this.inverseGroupedStaffName(name)
      wf_names.push(name)
    })
    return wf_names
  }
  static inverseGroupedStaffName(name){
    console.log("-> inverseGroupedStaffName", name)
    let letter1, letterX, counter_letter;
    letter1 = name.substr(0,1)
    letterX = name.substr(name.length - 1, 1)
    if ( ( letter1 == '{' ) || ( letter1 == '[') ) {
      counter_letter = (letter1 == '{') ? '}' : ']'
      name = name.substr(1, name.length) + counter_letter
    } else if ( (letterX == '}') || (letterX == ']') ) {
      counter_letter = (letterX == '}') ? '{' : '['
      name = counter_letter + name.substr(0, name.length - 1)
    }
    return name
  }

  static buildMenuKeys(selectedValue){
    const menu = DCreate('SELECT', {class:'staff-cle'});
    ['G', 'F', 'UT3' , 'UT4', 'UT2', 'UT1', 'F3'].forEach( cle => {
      const sele = selectedValue == cle ? true : false;
      menu.appendChild(DCreate('OPTION',{text: cle, selected:sele}))
    })
    return menu
  }

  static get stavesContainer(){
    return this._stavescont || (this._stavescont = DGet('#staves-container'))
  }

  /**
  * = main =
  * 
  * Une méthode principale qui extrait du code MUS toutes les options
  * définies (par l’amorce ’--<key option>’)
  */
  static extractOptionsFrom(musCode){
    // console.log("-> extractOptionsFrom avec : ", musCode)
    const notOptions = []
    const options = {}
    musCode.split("\n").forEach( line => {
      if ( line.substr(0,2) == '--' ) {
        let line_option = line.substr(2).trim().split(' ')
        let option  = line_option.shift()
        let value   = line_option.length && line_option.join(' ')
        switch(option){
        case 'piano':case 'quatuor':
          value  = String(option)
          option = 'system'
          break
        default:
          value || (value = true)
          if ( value == 'OFF' ) value = false
        }
        if ( String(value).match(/,/)){ 
          const ary = []
          console.log("Option %s", option, value.split(','))
          value.split(',').forEach( str => ary.push(str.trim()) )
          value = ary
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
