"use strict";

class Log {
    constructor(region, defname) {
        defname = defname.replace(/\s+/g, '_');
        this.region = region;
        this.defname = defname;
        this.defs = Object.create(null);
    }

    debug(name, value) {
        this.defs[name] = cull(value);
    }

    dump() {
        if (Object.keys(this.defs).length > 0) {
            console.log(this.region + "::" + this.defname, this.defs);
        }
    }
}

function getGlob(conn, context, iyg, cbb) {

    var oalias = {
        addressbook__c: 'addressbook',
        cntrbnmdl_tse__c: 'cmodel',
        rmav2__c: 'rma',
        _nec_case: 'neccase',
        _nec_asset: 'necasset',
    };

    var mixins = {
        Generic: [],
        Account: [
            { obj: 'account' }
        ],
        Asset: [
            { obj: 'asset' },
            { obj: 'account', parent: 'asset', id: 'accountid' },
            { obj: 'addressbook__c', parent: 'asset', id: 'assetpartshipaddressbook__c' },
            { obj:'_nec_asset',      parent:'asset',    id: 'id' },
            { obj: 'contact', parent: 'asset', id: 'contactid' }
        ],
        Case: [
            { obj: 'case' },
            { obj: 'account', parent: 'case', id: 'accountid' },
            { obj: 'asset', parent: 'case', id: 'assetid' },
            //{ obj: '_nec_case', parent: 'case', id: 'id' },
            { obj:'_nec_asset',      parent:'case',     id: 'assetid' },
            { obj: 'contact', parent: 'case', id: 'contactid' }
        ],
        Contact: [
            { obj: 'contact' },
            { obj: 'account', parent: 'contact', id: 'accountid' }
        ],
        AddressBook: [
            { obj: 'addressbook__c' },
            { obj: 'account', parent: 'addressbook__c', id: 'abaccount__c' }
        ],
        RMA: [
            { obj: 'rmav2__c' },
            { obj: 'case', parent: 'rmav2__c', id: 'rmacasenumber__c' },
            { obj: 'account', parent: 'case', id: 'accountid' },
            { obj: 'account', parent: 'case', id: 'accountid' },
            { obj: 'asset', parent: 'case', id: 'assetid' },
            { obj: 'asset', parent: 'case', id: 'assetid' },
            // { obj: '_nec_case', parent: 'case', id: 'id' },
            { obj: '_nec_asset', parent: 'case', id: 'assetid' },
            { obj: 'addressbook__c', parent: 'asset', id: 'assetpartshipaddressbook__c' }
        ]
    };

    var glob = {};

    var waterpusher = function(k, v) {
        glob[k] = v;
    };

    var waterqueue = [];


    // waterqueue.push(
    //     function(cb) {
    //         cb(null, true);
    //     });


    // if(1==2) {

        waterqueue.push(
            function(cb) {

                var sql = `SELECT Id FROM CntrbnMdl_TSE__c WHERE Employee_Name__c='${iyg.user.id}' ORDER BY lastmodifieddate DESC LIMIT 1`;

                conn.query(sql, function(err, result) {
                    if (err) throw err;

                    // console.log(result);

                    if (result.totalSize) {
                        var cid = result.records[0].Id;
                        conn.sobject('CntrbnMdl_TSE__c').retrieve(cid, function(err, result) {
                            if (err) throw err;
                            // console.log('wq', 'cmodel', cid, result);
                            waterpusher('cmodel', casesub(result));
                            cb(null, true);
                        });
                    } else {
                        waterpusher('cmodel', {});
                        // console.log('wq', 'cmodel', 'undef');
                        cb(null, true);
                    }

                });

            }
        );

    // }

    // console.log(context);

    mixins[context.name].forEach(function(e) {
        //  console.log(e);

        waterqueue.push(function(x, cb) {

            var rid = e.id ? glob[e.parent][e.id] : context.id;

            if (rid) {
                if (e.obj.match(/^_nec_case/)) {

                    conn.query(`SELECT necrKeyName__r.Name, necrValue__c FROM NEC_Record__c WHERE necrCase__c='${rid}'`, function(err, result) {
                        if (err) throw err;
                        var nec = {};
                        result.records.forEach(function(e) {
                            nec[e.necrKeyName__r.Name] = fixup(e.necrValue__c);
                        });
                        waterpusher('neccase', casesub(nec));
                        cb(null, true);
                    });

                } else if (e.obj.match(/^_nec_asset/)) {
                    conn.query(`SELECT necrKeyName__r.Name, necrValue__c FROM NEC_Record__c WHERE necAsset__c='${rid}'`, function(err, result) {
                        if (err) throw err;
                        var nec = {};
                        result.records.forEach(function(e) {
                            nec[e.necrKeyName__r.Name] = fixup(e.necrValue__c);
                        });
                        waterpusher('necasset', casesub(nec));
                        cb(null, true);
                    });

                } else {
                    conn.sobject(e.obj).retrieve(rid, function(err, result) {
                        if (err) throw err;
                        // console.log('wq: ', e.obj, rid, result);
                        waterpusher(e.obj, casesub(result));
                        cb(null, true);
                    });
                }
            } else {
                // console.log('wq', e.obj, 'undef', e.parent, e.id);
                waterpusher(e.obj, {});
                cb(null, true);
            }
        });

    });

    async.waterfall(waterqueue,
                    function(err) {
                        if (err) throw err;

                        Object.keys(glob).forEach(function(k) {
                            if (oalias[k]) {
                                glob[oalias[k]] = glob[k];
                                delete glob[k];
                            }
                        });

                        // console.log('wf', 'glob', glob);
                        cbb(glob);
                    });
}

function whereami(iyg) {

    var context = iyg.region;

    var pageid = iyg.pageid;

    let types = {
        '001': 'Account',
        '02i': 'Asset',
        'a38': 'AddressBook',
        '500': 'Case',
        '003': 'Contact',
        'a2D': 'RMA'
    };

    var glob = { id: null, name: "Generic", context: context };

    if (pageid && types[pageid.substr(0, 3)]) {
        glob.id = pageid;
        glob.name = types[pageid.substr(0, 3)];
        glob.context = context;
    }

    return glob;
}

function casesub(obj) {

    if (!obj) return;

    var key, keys = Object.keys(obj);
    var n = keys.length;
    var newobj = {};
    while (n--) {
        key = keys[n];
        newobj[key.toLowerCase()] = obj[key];
    }

    fixups(newobj);
    return newobj;
}

function fixup(val) {

    if (typeof val == "string" && val == 'true')
        return true;
    if (typeof val == "string" && val == 'false')
        return false;

    if (typeof val == "string" && (val.match(/^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\d\+\d\d\d\d$/) || val.match(/^\d\d\d\d-\d\d-\d\d$/))) {
        val = Date.parse(val);
        return val;
    }

    return val;
}

function fixups(val) {

    if (typeof val == "object") {
        for (const [key, value] of Object.entries(val)) {
            if (typeof value == "string" && (value.match(/^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\d\+\d\d\d\d$/) || value.match(/^\d\d\d\d-\d\d-\d\d$/))) {
                // obj[key = "__o"] = value;
                // obj[key] = Date.parse(value);
                // // console.log(key, obj[key]);

                val[key + '__ts'] = luxon.DateTime.fromISO(value).toSeconds();

                // var lux = luxon.DateTime.fromISO(value);
                // var luxs = luxon.DateTime.fromISO(value).toSeconds();
                // console.log(`lux(${lux}) luxs(${luxs}) val(${value})`);
            }
        }
    }

    return val;
}

function evil(cli, sfdc) {
    'use strict';
    var rc;

    try {
        rc = eval(cli) || false;
    } catch (err) {
        if (err) throw err;
    }
    return rc;
}

// eslint-disable-next-line no-unused-vars
function iyg(iyg) {

    let stateCheck = setInterval(() => {
        if (document.readyState === 'complete') {
            clearInterval(stateCheck);
            iygRunner(iyg);
        }
    }, 100);
}

function iygRunner(iyg) {

    var conn = new jsforce.Connection({ accessToken: iyg.sid });
    var context = whereami(iyg);

    getGlob(conn, context, iyg, function(sfdc) {

        sfdc.env = cull(iyg, sfdc);
        sfdc.now = luxon.DateTime.local().toSeconds();
        // console.log('sfdc:', sfdc);

        var sql = [
            "SELECT Id, Name, Verbiage__c, Link__c, Evaluation_Context__c, Logic__c, Tooltip__c, Debugging__c, Iconography__c, Style__c, Private_Use__c, OwnerId, IsHidden__c, Parent_Definition__c",
            "FROM IYG_Definition__c",
            "WHERE IsActive__c=true and Evaluation_Context__c includes ('" + context.name + "') and Display_Contexts__c includes('" + context.context + "')",
            "ORDER BY Ranking__c DESC NULLS LAST",
        ].join(' ');

        conn.query(sql, function(err, res) {
            if (err) throw err;

            var defstack = [];
            var defhash = {};

            res.records.forEach(function(e) {

                var logger = new Log(iyg.region, e.Name);

                e._domid = '#iyg_' + context.context;
                e.Logic__c = e.Logic__c.replace(/\s+/g, ' ');

                if (e.Debugging__c) {
                    logger.debug("context", context.name);
                    logger.debug("sfdc", sfdc);
                    logger.debug("logic", e.Logic__c);
                }

                try {
                    var rc = evil(e.Logic__c, sfdc);

                    if (e.Debugging__c) {
                        logger.debug("returnCode", rc);
                    }

                    e._rc = rc;
                    if (rc == true) {
                        // if( rc == true || rc == "ok") {

                        var li = ['<li id="' + e.Id + '" ',
                                  'data-name="',
                                  e.Name,
                                  '" ',
                                  e.Tooltip__c ? 'data-tippy-content="<small>' + Mustache.render(e.Tooltip__c, { sfdc: sfdc }) + '</small>"' : '',
                                  '>',
                                  '<span class="fa-li">' + e.Iconography__c + '</span>',
                                  '<a href="',
                                  Mustache.render(e.Link__c, { sfdc: sfdc }),
                                  '" target="_blank"',
                                  'style="' + e.Style__c + '"',
                                  '>',
                                  Mustache.render(e.Verbiage__c, { sfdc: sfdc }),
                                  '</a>',
                                  '</li>'
                                 ].join('');

                        e._li = li;
                    }

                    defstack.push(e);
                    defhash[e.Id] = e;

                } catch (err) {
                    if (e.Debugging__c) {
                        // console.log("fatal return(%s, '%s'='%s')", false, err.name, err.message);
                        logger.debug("fatal", `${err.name}=${err.message}`)
                    }
                }

                if (e.Debugging__c) {
                    logger.dump();
                }

            });

            // show what we gotta show
            for (var e of defstack) {
                if (!((e.IsHidden__c) ||
                      (e._rc != true) ||
                      (e.Parent_Definition__c && defhash[e.Parent_Definition__c]._rc == false) ||
                      (e.Private_Use__c && e.OwnerId != iyg.user.id))) {
                    $(e._domid).append(e._li);
                }
            }

            tippy('[data-tippy-content]', {
                // arrow: false,
                interactive: true,
                allowHTML: true,
            });

        });
    });
}

// de-prototype object
function cull(obj) {
    if (typeof obj != "object")
        return obj;
    var tmp = Object.create(null);
    for (const [k, v] of Object.entries(obj)) {
        tmp[k] = v;
    }
    delete tmp.attributes;
    delete tmp.__proto__;
    return tmp;
}
