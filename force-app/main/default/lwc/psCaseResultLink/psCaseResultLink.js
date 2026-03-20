import navigateToRecord from '@salesforce/label/c.quantic_NavigateToRecord';
import opensInBrowserTab from '@salesforce/label/c.quantic_OpensInBrowserTab';
import {
  getHeadlessBundle,
  getHeadlessEnginePromise,
} from 'c/quanticHeadlessLoader';
import {ResultUtils} from 'c/quanticUtils';
import {NavigationMixin} from 'lightning/navigation';
import {LightningElement, api} from 'lwc';

/**
 * Some document types cannot be opened directly in Salesforce, but we need to open their parent record, as is the case for the Case Comment document type.
 */
const documentTypesRequiringParentRecord = ['CaseComment'];

/** @typedef {import("coveo").Result} Result */
/** @typedef {import("coveo").SearchEngine} SearchEngine */

/**
 * The `PsCaseResultLink` component creates a clickable link from a case result that points to the original item.
 * If the result is a Salesforce record or a Salesforce Knowledge article it will open the link in a new salesforce console subtab.
 * Otherwise, it will open the link in the browser tab.
 * @category Result Template
 * @example
 * <c-ps-case-result-link engine-id={engineId} result={result} target="_blank"></c-ps-case-result-link>
 */
export default class PsCaseResultLink extends NavigationMixin(
  LightningElement
) {
  /**
   * The ID of the engine instance the component registers to.
   * @api
   * @type {string}
   */
  @api engineId;
  /**
   * The [result item](https://docs.coveo.com/en/headless/latest/reference/search/controllers/result-list/#result).
   * @api
   * @type {Result}
   */
  @api result;
  /**
   * Where to display the linked URL, as the name for a browsing context (a tab, window, or <iframe>).
   * The following keywords have special meanings for where to load the URL:
   *   - `_self`: the current browsing context. (Default)
   *   - `_blank`: usually a new tab, but users can configure their browsers to open a new window instead.
   *   - `_parent`: the parent of the current browsing context. If there’s no parent, this behaves as `_self`.
   *   - `_top`: the topmost browsing context (the "highest" context that’s an ancestor of the current one). If there are no ancestors, this behaves as `_self`.
   * @api
   * @type {string}
   * @defaultValue `'_self'`
   */
  @api target = '_self';
  /**
   * Indicates the use case where this component is used.
   * @api
   * @type {'search'|'case-assist'}
   * @deprecated The component uses the same Headless bundle as the interface it is bound to.
   * @defaultValue `'search'`
   */
  @api useCase = 'search';
  /**
   * A function used to set focus to the link.
   * @api
   * @type {VoidFunction}
   */
  @api setFocus() {
    const focusTarget = this.template.querySelector('a');
    if (focusTarget) {
      // @ts-ignore
      focusTarget.focus();
    }
  }
  /**
   * Indicates the result field to display as the link text.
   * @api
   * @type {string}
   * @defaultValue `'title'`
   */
  @api displayedField = 'title';

  /** @type {SearchEngine} */
  engine;
  /** @type {AnyHeadless} */
  headless;

  labels = {
    navigateToRecord,
    opensInBrowserTab,
  };

  connectedCallback() {
    getHeadlessEnginePromise(this.engineId)
      .then((engine) => {
        this.initialize(engine);
      })
      .catch((error) => {
        console.error(error.message);
      });
  }

  /**
   * @param {SearchEngine} engine
   */
  initialize = (engine) => {
    this.headless = getHeadlessBundle(this.engineId);
    this.engine = engine;
    ResultUtils.bindClickEventsOnResult(
      this.engine,
      this.result,
      this.template,
      this.headless.buildInteractiveResult
    );
  };

  get recordIdAttribute() {
    // Knowledge article uses the knowledge article version id to navigate.
    if (this.result?.raw?.sfkbid && this.result?.raw?.sfkavid) {
      return this.result.raw.sfkavid;
    }
    if (this.shouldOpenParentRecord) {
      return this.result?.raw?.sfparentid;
    }
    return this.result.raw.sfid;
  }

  get shouldOpenParentRecord() {
    return (
      documentTypesRequiringParentRecord.includes(
        this.result?.raw?.documenttype
      ) && this.result?.raw?.sfparentid
    );
  }

  /**
   * Checks if the Result type is Salesforce.
   */
  get isSalesforceLink() {
    return !!this.result?.raw?.sfid;
  }

  /**
   * Returns the result field to display as the link title.
   */
  get fieldToDisplay() {
    return this.result[this.displayedField] ||
      this.result.raw?.[this.displayedField]
      ? this.displayedField
      : 'clickUri';
  }

  /**
   * Returns the aria label value for the link.
   */
  get ariaLabelValue() {
    return this.labels.navigateToRecord;
  }

  get hrefValue() {
    return `/lightning/r/Case/${this.result.raw.sfid}/view`;
  }
}