import { LightningElement, api, track } from 'lwc';
import {
  registerComponentForInit,
  initializeWithHeadless,
  getHeadlessBundle,
} from 'c/quanticHeadlessLoader';
// @ts-ignore
import caseTemplate from './resultTemplates/Cases.html';
// @ts-ignore
import defaultTemplate from './resultTemplates/Default.html';

export default class PsQuanticFullSearchPage extends LightningElement {
  /** @type {string} */
  @api engineId = 'quantic-ps-engine';
  /** @type {string} */
  @api searchHub = 'general-search';
  /** @type {string} */
  @api pipeline = 'Corporate search';
  /** @type {boolean} */
  @api disableStateInUrl = false;
  /** @type {boolean} */
  @api skipFirstSearch = false;

  /** @type {ResultList} */
  resultList;
  /** @type {Function} */
  unsubscribe;
  /** @type {Function} */
  unsubscribeSearchStatus;
  /** @type {SearchEngine} */
  engine;
  /** @type {Object} */
  selectedTab;


  connectedCallback() {
    registerComponentForInit(this, this.engineId);
  }

  renderedCallback() {
    initializeWithHeadless(this, this.engineId, this.initialize);
  }
  
  
  /**
   * @param {SearchEngine} engine
   */
  initialize = (engine) => {
    this.headless = getHeadlessBundle(this.engineId);

    this.engine = engine;
    this.unsubscribe = engine.subscribe(() => {
      this.watchTabChanges();
    });
  };

  disconnectedCallback() {
    this.unsubscribe?.();
  }

  handleResultTemplateRegistration(event) {
    event.stopPropagation();

    const resultTemplatesManager = event.detail;

    const isCase = CoveoHeadless.ResultTemplatesHelpers.fieldMustMatch(
      'objecttype',
      ['Case']
    );

    resultTemplatesManager.registerTemplates(

      {
        content: caseTemplate,
        conditions: [isCase],
        fields: [
            'commonsource', 
            'excerpt', 
            'clickableuri', 
            'date', 
            'filetype', 
            'sfcasenumber', 
            'sfrecordtypename', 
            'sfassetassetnimbleosversion__c', 
            'sfbugs__rbugid__c', 
            'sftechnology_area__c', 
            'sfsub_technology_area__c', 
            'sfsupport_profile__c',
        ], 
        priority: 0
      },
      {
        content: defaultTemplate,
        conditions: [],
        fields: ['commonsource', 'excerpt', 'clickableuri', 'date', 'filetype', 'kcs_doc_id', 'nimble_public_uri'],
        priority: 0
      }
    );
  }

  watchTabChanges() {
    if (this.engine.state.tabSet) {
      this.selectedTab = Object.values(this.engine.state.tabSet)?.find(
        (tab) => tab.isActive
      );
    }
  }

  get isAllTab() {
    return this.selectedTab?.id === 'All';
  }

  get isNotAllTab() {
    return !this.isAllTab;
  }

}