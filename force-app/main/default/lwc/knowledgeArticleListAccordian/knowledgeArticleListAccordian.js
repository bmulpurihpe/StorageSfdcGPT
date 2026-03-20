import { LightningElement, api } from 'lwc';

export default class KnowledgeArticleListAccordian extends LightningElement {
    @api articleId
    @api title;
    @api articleRecordType;
    @api articleNumber;
    @api urlName;
    @api summary;
    @api product;
    @api techSkillset;
    @api softwareVersion;
    @api disclosureLevel;
    showDetails = false;

    toggleArticleDetailSection() {
        this.showDetails = !this.showDetails;
    }

    viewArticleDetail(event) {
        let articleId = this.articleId;
        let title = this.title;
        let articleRecordType = this.articleRecordType;
        let urlName = this.urlName;
        const viewClickEvent = new CustomEvent("viewarticledetail", {
            detail: JSON.stringify({
                articleId: articleId,
                title: title,
                articleRecordType: articleRecordType,
                urlName: urlName
            })
        });
        this.dispatchEvent(viewClickEvent);
    }
}