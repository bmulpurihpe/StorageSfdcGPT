import { LightningElement, wire, track, api } from 'lwc';
import getKnowledgeArticles from '@salesforce/apex/KnowledgeArticleController.getKnowledgeArticles';
import getDataCategoriesForArticle from '@salesforce/apex/KnowledgeArticleController.getDataCategoriesForArticle';

export default class KnowledgeArticleListViewLwc extends LightningElement {
    articleData = [];
    @track filteredArticleData;
    @api selectedArticleId;
    @api selectedArticleTitle;
    @api selectedArticleRecordType;
    @api guestUserName;
    @api limitedView = false;
    @api urlName;
    selectedSummaryCard;
    showArticleDetails = false;
    dataCategoryResult;
    dataCategorySelections;
    noRecordsFound = false;

    //Page Navigation variables
    pageSizeOptionsCombo = [
                            {label: "5", value: "5"}, 
                            {label: "10", value: "10"},
                            {label: "25", value: "25"},
                            {label: "50", value: "50"},
                            {label: "75", value: "75"},
                            {label: "100", value: "100"}
                        ];
    pageSize;
    totalPages;
    pageNumber = 1;
    recordsToDisplay = [];

    get bDisableFirst() {
        return this.pageNumber == 1;
    }
    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }

    get inputVariables() {
        return [
            {
                name: 'recordId',
                type: 'String',
                value: this.selectedArticleId
            }
        ];
    }

    renderedCallback() {
        this.toggleSummaryCardStyle(this.selectedArticleId);
    }
    
    @wire(getKnowledgeArticles, {limitedView: '$limitedView'})
    getArticles({data, error}) {
        if(data) {
            this.filteredArticleData = this.articleData = data;
            this.pageSize = this.pageSizeOptionsCombo[0].value;
            this.totalRecords = this.filteredArticleData.length;
            this.paginationHelper();
            if(this.urlName) {
                let articleData = this.filteredArticleData.filter(a => a.UrlName === this.urlName);
                if(articleData.length) {
                    this.displayArticleDetail(articleData[0].Id, articleData[0].Title, articleData[0].ArticleRecordType, this.urlName);
                } else {
                    this.noRecordsFound = true;
                }
            }
        } else {
            console.log("Error in getAllKnowledgeArticles: " + JSON.stringify(error));
        }
    }
    
    articleDetailViewClick(event) {
        let articleData = JSON.parse(event.detail);
        this.displayArticleDetail(articleData.articleId, articleData.title, articleData.articleRecordType, articleData.urlName);
    }

    displayArticleDetail(id, title, recordType, urlName) {
        this.selectedArticleId = id;
        this.selectedArticleTitle = title;
        this.selectedArticleRecordType = recordType;
        this.dataCategorySelections = [];
        this.getDataCategoriesForArticle()
        this.noRecordsFound = false;
        this.showArticleDetails = true;

        //const newUrl = this.appName + "/article/" + urlName;
        const newUrl = '/sf-knowledge-viewer/article/' + urlName;
        const newState = {page: "new"};
        window.history.pushState(newState, "Knowledge View - Article Detail", newUrl);
    }

    getDataCategoriesForArticle() {
        getDataCategoriesForArticle({articleId: this.selectedArticleId})
            .then((result) => {
                if(result.length > 0) {
                    console.log("data categories result: " + JSON.stringify(result));
                    this.dataCategoryResult = result;
                    this.createDataCategoryTree();
                }
            })
            .catch((error) => {
                console.log("Error getting data categores: ", error);
            })
    }

    createDataCategoryTree() {
        var dataCategory = this.dataCategoryResult;
        var result = [];

        dataCategory.forEach((item) => {
            if(!result.some(res => res.name === item.DataCategoryGroupName)) {
                    result.push({
                        label: item.DataCategoryGroupName,
                        name: item.DataCategoryGroupName,
                        expanded: true,
                        items: dataCategory.filter(dc => dc.DataCategoryGroupName === item.DataCategoryGroupName)
                                                .map(dc1 => {
                                                    return {
                                                        label: dc1.DataCategoryName,
                                                        name: dc1.DataCategoryName,
                                                        expanded: true
                                                    }
                                                })
                    });
            }
        });
            
        console.log(JSON.stringify(result));
        this.dataCategorySelections = result;
    }

    toggleSummaryCardStyle(articleId) {
        this.template.querySelectorAll('c-knowledge-article-list-accordian').forEach(item => {
            if (item.articleId === articleId) {
                item.style.setProperty("--sds-c-card-color-background", "#00C8FF");
            } else {
                item.style.setProperty("--sds-c-card-color-background", "white");
            }
        });
    }

    applySearchFilter(event) {
        if(event.detail.value.length >= 3) {
            const dataToFilter = this.articleData;
            var searchText = event.detail.value;
            const result = dataToFilter.filter(data => data.Title.toLowerCase().includes(searchText.toLowerCase())
                                                    || data.UrlName.includes(searchText.toLowerCase()));
            this.filteredArticleData = result;
        } else {
            this.filteredArticleData = this.articleData;
        }
        this.totalRecords = this.filteredArticleData.length;
        this.paginationHelper();
    }

    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.paginationHelper();
    }
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }
    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }
    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }
    
    paginationHelper() {
        this.recordsToDisplay = [];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(this.filteredArticleData[i]);
        }
    }
}