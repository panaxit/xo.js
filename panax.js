px = {}
xover.qrl = xover.QUERI;
xover.QRL = xover.QUERI;
xo.spaces["px"] = "http://panax.io/entity";
xo.spaces["data"] = "http://panax.io/source";
Object.defineProperty(xo.session, 'login', {
    value: async function (username, password, connection_id = window.location.hostname) {
        try {
            let _username = username.value || username
            let _password = password.value || password
            xover.session.user_login = _username
            xover.session.status = 'authorizing';
            let response = await xover.server.login(new URLSearchParams({ 'connection_id': connection_id }), { headers: { authorization: `Basic ${btoa(_username + ':' + _password)}` } });
            xover.session.status = 'authorized';
            if (xover.site.seed === '#login') {
                xover.site.seed = '#';
            } else {
                xover.stores.active.render();
            }
        } catch (e) {
            xover.session.status = 'unauthorized';
            Promise.reject(e);
        }
    }, writable: true, configurable: true
})

Object.defineProperty(xo.session, 'logout', {
    value: async function () {
        try {
            let response = await xover.server.logout();
            let positions = -xo.site.position + 1;
            //if (positions) {
            //    history.go(positions);
            //}
            for (store in xo.stores) {
                xo.stores[store].remove()
            }
            xover.session.status = 'unauthorized';
        } catch (e) {
            Promise.reject(e);
        }
    }, writable: true, configurable: true
})

xo.listener.on(['beforeRender::#shell', 'beforeAppendTo::html:main', 'beforeAppendTo::html:body'], function ({ target, event }) {
    if (!(event.detail.args || []).filter(el => !(el instanceof Comment || el instanceof HTMLStyleElement || el instanceof HTMLScriptElement || el.matches("dialog,[role=alertdialog],[role=alert],[role=dialog],[role=status],[role=progressbar]"))).length) return;
    [...target.childNodes].filter(el => el.matches && !el.matches(`script,dialog,[role=alertdialog],[role=alert],[role=dialog],[role=status],[role=progressbar]`)).removeAll()
})

xo.listener.on([`beforeRemove::html:div[@role='alertdialog'][contains(*/@class,'modal')]`], function () {
    let removed_from = this;
    let store = removed_from.getAttribute("xo-store");
    if (store && store in xover.stores) {
        delete xover.stores[store];
    }
    let scope = this.scope;
    scope instanceof Attr && scope.remove()
})

//xo.listener.on(['focus::input'], function () {
//    this.select();
//})

xo.listener.on(['render::*'], function () {
    this.selectNodes("//button[not(@type)]").forEach(el => el.set("type", "button")) //default behavior
})

xo.listener.on(['removeFrom::data:rows'], function ({ }) {
    if (!this.select("*").length) {
        this.setAttribute("xsi:nil", true)
    }
})

xo.listener.on([`set::xo:r[@state:new="true"]/@state:checked[.="false"]`, `remove::xo:r[@state:new="true"]/@state:checked`], function () {
    this.parentNode.remove();
})

xo.listener.on([`change::px:Association[@DataType='junctionTable']/px:Entity/px:Record/px:Association[@Name=../../*[local-name()='layout']/association:ref/@Name]/px:Entity/data:rows/xo:r/@state:checked[.="true"]`], function ({ element }) {
    let association_ref = element.selectFirst(`ancestor::px:Association[1]`);
    let target = association_ref.selectFirst(`ancestor::px:Entity[1]/data:rows`);

    let referencers = association_ref.select('px:Mappings/px:Mapping/@Referencer').map(referencer => [referencer.value, referencer.parentNode.getAttribute("Referencee")]);

    let node = xo.xml.createNode(`<xo:r xmlns:xo="http://panax.io/xover" xmlns:state="http://panax.io/state" state:checked="true" state:new="true" state:dirty="true" ${target.select(`../px:Record/*/@Name`).map(attr => `${attr.matches("px:Association/@Name") ? 'meta:' : ''}${attr.value}=""`).join(" ")}/>`).reseed();
    for (let [referencer, referencee] of referencers) {
        node.setAttribute(referencer, element.getAttribute(referencee))
        node.srcElement = element;
    }
    node.setAttribute(`meta:${association_ref.getAttribute("Name")}`, element.getAttribute("meta:text"), { silent: true });

    target && target.append(node);
})

xo.listener.on(['change::px:Association[@DataType="junctionTable"]/px:Entity/data:rows/xo:r[not(@meta:id!="")]/@state:checked[.="false"]', 'remove::px:Association[@DataType="junctionTable"]/px:Entity/data:rows/xo:r[not(@meta:id!="")]/@state:checked'], function ({ element }) {
    let target = element.selectFirst(`ancestor::px:Entity[1]/data:rows[@xsi:type="mock"]`);
    target && target.append(element);
})

xo.listener.on(['change::@meta:pageIndex', 'change::@meta:pageSize'], function ({ element, value }) {
    let command = element.get(`command`);
    if (command) {
        command = xo.QUERI(command)
        command.headers.set(this.localName, value);
    }
    command.update()
})

/*xo.listener.on(['change::@meta:*[.=""]'], function ({ element: row }) { //disabled
    let association = this.schema;
    if (!association) return;
    for (let mapping of association.select("px:Mappings/px:Mapping/@Referencer")) {
        row.set(mapping.value, "");
    }
})*/

xo.listener.on(['beforeTransform::px:Entity'], function ({ event }) {
    let node = this;

    for (let association_ref of node.select(`//px:Association[@DataType='junctionTable']/px:Entity/px:Record/px:Association[@Name=../../*[local-name()='layout']/association:ref/@Name][px:Entity/data:rows/xo:r]`)) {
        let selected_options = association_ref.select(`ancestor::px:Association[1]/px:Entity/data:rows/xo:r`);
        if (!selected_options.length) continue;

        let referencers = association_ref.select('px:Mappings/px:Mapping/@Referencer').map(referencer => [referencer.value, referencer.parentNode.getAttribute("Referencee")]);
        if (!referencers.length) return;

        for (let row of association_ref.select(`px:Entity/data:rows/xo:r`)) {
            let match = selected_options.find(selected_row => referencers.every(([referencer, referencee]) => selected_row.getAttribute(referencer) == row.getAttribute(referencee)));
            if (match) {
                match.disconnect();
                match.setAttribute("meta:position", row.getAttribute("meta:position"));
                row.remove({ silent: true });
            }
        }
    }

    for (let association_ref of node.select(`//px:Entity/px:Record/px:Association[@Type="belongsTo"][px:Mappings/px:Mapping[2]]`)) {
        if (!xo.site.sections[event.detail.stylesheet.href].find(section => section.querySelector(`[xo-attribute="meta:${association_ref.getAttribute("Name")}"]`))) return;
        let referencers = Object.fromEntries(association_ref.select('px:Mappings/px:Mapping[not(@Referencee=ancestor::px:Entity[1]/@IdentityKey)]/@Referencer').map(referencer => [referencer.value, referencer.parentNode.getAttribute("Referencee")]));
        let row = association_ref.select(`ancestor::px:Entity[1]/data:rows/xo:r/@*`).filter(attr => Object.keys(referencers).includes(attr.name));
        let data_rows = association_ref.selectFirst(`px:Entity[@IdentityKey]/data:rows`);
        let rows = data_rows && data_rows.select(`xo:r`).filter(_row => row.filter(attr => _row.get(referencers[attr.name]) != attr.value).length) || [];
        if (rows.length) {
            rows.removeAll({ silent: true });
            if (!data_rows.select("xo:r").length) {
                data_rows.setAttribute("xsi:nil", true);
                //row.map(attr => store.find(attr.parentNode).getAttributeNode(`meta:${association_ref.getAttribute("AssociationName")}`)).filter(el => el.value).forEach(attr => attr.set(""));
            }
        }
    }
})

xo.listener.on(`change::xo:r/@*[not(contains(namespace-uri(),'http://panax.io/state'))]`, function ({ element: row, attribute, old, value }) {
    let initial_value = row.getAttributeNodeNS('http://panax.io/state/initial', attribute.nodeName.replace(':', '-'));
    row.select(`@xsi:type[.="mock"]`).remove();
    row.set(`state:dirty`, 1);
    if (initial_value) {
        initial_value == value && initial_value.remove();
    } else if (value !== null) {
        row.set(`initial:${attribute.nodeName.replace(':', '-')}`, old);
    }
    row.set(`prev:${attribute.nodeName.replace(':', '-')}`, old);
})

//xo.listener.on(`change::xo:r/@meta:*`, function ({ node, element, attribute, old, value }) {
//    let referencers = element.$$(`ancestor::px:Entity[1]/px:Record/px:Association[@AssociationName="${node.localName}"]/px:Mappings/px:Mapping/@Referencer`);
//    let options = element.select(`ancestor-or-self::px:Entity[1]/px:Record/px:Association[@Type="belongsTo"][@AssociationName="${node.localName}"]/px:Entity/data:rows/xo:r`);
//    let matches = options.filter(option => referencers.every(referencer => selected_record.getAttribute(referencer.value) == option.getAttribute(referencer.ownerElement.getAttribute("Referencee"))));
//    console.log("here!")
//})

//xo.listener.on(`beforeChange::xo:r/@meta:*`, function ({ node, element, attribute, old, value }) {
//    let src_element = event.srcEvent.target;
//    if (!src_element instanceof HTMLElement) return;

//    let selected_record = src_element instanceof HTMLSelectElement && src_element[src_element.selectedIndex].scope.filter("self::xo:r") || src_element instanceof HTMLLIElement && src_element.scope.filter("self::xo:r") || undefined;
//    if (selected_record) {
//        this.parentNode.set(`selected:${this.localName}`, selected_record.getAttribute("xo:id"));
//        px.selectRecord(selected_record, node);
//        if (src_element instanceof HTMLSelectElement) {
//            let option = src_element[src_element.selectedIndex]
//            this.value = option.value && option.text || "";
//        } else if (src_element instanceof HTMLLIElement) {
//            let option = src_element;
//            this.value = option.textContent;
//        }
//    }
//})

xo.listener.on(`change::html:select`, function ({ node, element, attribute, old, value }) {
    let src_element = this;
    if (!src_element instanceof HTMLElement) return;
    let scope = src_element.scope;
    let selected_record = src_element instanceof HTMLSelectElement && (src_element[src_element.selectedIndex].scope || src_element[src_element.selectedIndex].scope);
    if (scope instanceof Attr) {
        //px.selectRecord(selected_record instanceof Element && selected_record || null, scope);
        scope.set(selected_record || "");
    }
})

xo.listener.on(`click::html:li`, function ({ node, element, attribute, old, value }) {
    let src_element = this;
    if (!src_element instanceof HTMLElement) return;
    let scope = (src_element.closest('ul,ol') || {}).scope;

    let selected_record = src_element instanceof HTMLLIElement && src_element.scope && src_element.scope.filter("self::xo:r").pop();
    if (scope && selected_record instanceof Element && selected_record && !selected_record.parentNode.selectFirst("ancestor::xo:r")) {
        src_element.parentNode.scope.dispatch('selectRecord', selected_record);
        //px.selectRecord(selected_record, src_element.parentNode.scope);
        let option = src_element;
        scope.set(option.textContent);
    }
})

xo.listener.on([`selectRecord::@*`, `selectRecord::*`], function ({ args, event }) {
    let target = this;
    let element = target.ownerElement || target;
    let selected_record = args[0];
    if (!element) {
        event.preventDefault();
        event.returnValue = false;
    };
    let referencers = element.$$(`ancestor::px:Entity[1]/px:Record/px:Association[@AssociationName="${target.localName}"]/px:Mappings/px:Mapping/@Referencer`);
    for (let referencer of referencers) {
        element.set(referencer.value, selected_record instanceof Element && selected_record.getAttribute(referencer.parentNode.getAttribute("Referencee")) || "");
    }
})

xo.listener.on([`beforeSet::xo:r/@meta:*`], function ({ value, old }) {
    //if (!(value.matches && value.matches("xo:r"))) return value;
    if (old == value) return value;
    let scope = this;
    let element = scope.ownerElement || scope;
    let referencers = element.$$(`ancestor::px:Entity[1]/px:Record/px:Association[@AssociationName="${scope.localName}"]/px:Mappings/px:Mapping/@Referencer`);
    let selected_record = value instanceof Node && value.matches("xo:r") && value || typeof (value) === 'string' && referencers[0].selectFirst(`ancestor::px:Association[1]/px:Entity/data:rows/xo:r[@meta:text="${value}"]`) || null;
    if (selected_record === null) {
        referencers = referencers.filter(referencer => referencer.parentNode.getAttribute("Referencee") == referencer.selectFirst(`ancestor::px:Association[1]/px:Entity/@IdentityKey`));
    }
    for (let referencer of referencers) {
        let new_value = selected_record instanceof Element && selected_record.getAttribute(referencer.parentNode.getAttribute("Referencee")) || "";
        if (element.getAttribute(referencer.value) != new_value) {
            element.set(referencer.value, new_value);
        }
    }
    selected_record = selected_record instanceof Node && selected_record.getAttributeNode("meta:text") || selected_record || "";
    scope.dispatch('selectRecord', selected_record instanceof Node && selected_record.selectFirst(`ancestor-or-self::xo:r[1]`) || null);
    return selected_record;
})

px.selectRecord = function (selected_record, target) {
    let element = target.ownerElement || target;
    if (!element) {
        event.preventDefault();
        event.returnValue = false;
    };
    let referencers = element.$$(`ancestor::px:Entity[1]/px:Record/px:Association[@AssociationName="${target.localName}"]/px:Mappings/px:Mapping/@Referencer`);
    for (let referencer of referencers) {
        element.set(referencer.value, selected_record instanceof Element && selected_record.getAttribute(referencer.parentNode.getAttribute("Referencee")) || "");
    }
    //let associations = element.$$(`ancestor::px:Entity[1]/px:Record/px:Association[@Type='belongsTo']/px:Mappings/px:Mapping/@Referencer[.="${node.name}"]`);
}

xo.listener.on(`change::xo:r/@*[not(contains(namespace-uri(),'http://panax.io/state')) and not(contains(namespace-uri(),'http://panax.io/metadata'))]`, async function ({ node, element: row, attribute, old, value }) {
    this.freeze();
    let field = (node.schema || {});
    if (!field) return;
    let referencers = row.$$(`ancestor::px:Entity[1]/px:Record/px:Association[@Type='belongsTo']/px:Mappings/px:Mapping/@Referencer[.="${node.name}"]`);
    for (let referencer of referencers) {
        for (let mapping of referencer.select("ancestor::px:Mappings/px:Mapping/@Referencer")) {
            let previous_fields = mapping.selectFirst(`ancestor::px:Record[1]/px:Field[@Name="${mapping}"]`).select("@Name|preceding-sibling::px:Field/@Name").map(field => field.value);
            let filters = mapping.select(`ancestor::px:Mappings/px:Mapping/@Referencer`).filter(ref => previous_fields.includes(ref.value)).map(ref => [ref.parentNode.getAttribute("Referencee"), row.getAttribute(ref.value)]);
            let association_name = mapping.selectFirst(`ancestor::px:Association[1]/@Name`);
            let catalog = mapping.selectFirst("ancestor::px:Association[1]/px:Entity");
            let options = catalog.select("data:rows/xo:r");
            let meta_attribute = row.getAttributeNode(`meta:${association_name}`);
            if (!options.length) {
                let downloader = meta_attribute.dispatch('downloadCatalog')
                console.log(downloader);
            }
            if (!options.find(item => filters.every(([key, value]) => item.getAttribute(key) == value))) {
                row.getAttribute(mapping.value) && row.setAttribute(mapping.value, "");
                if (meta_attribute.value) meta_attribute = "";
            }
        }
    }

    let associated_references = row.$$(`px:Association[contains(@DataType,'Table')]/px:Mappings/px:Mapping/@Referencer[.="${node.name}"]`);
    for (let referencer of associated_references) {
        let associated_records = referencer.select(`ancestor::px:Entity[1]/data:rows/xo:r/@*[name()="${referencer.value}"]`)
        associated_records.forEach(attr => attr.value = value)
    }
})

xo.listener.on(`change::px:Entity[px:Record/px:Field/@formula]/data:rows/xo:r/@*[not(contains(namespace-uri(),'http://panax.io/'))]`, function ({ element: row, attribute, old, value }) {
    const CONVERT = function (type, ...args) {
        if (args.length != 1) return args;
        let value = args[0];
        let [, base_type, precision, scale] = type.match(/^([^\)]+)(?:\((\d+),(\d+)\))?$/);
        if (type.indexOf('(') != -1) {
            if (isNumber(value) && scale) {
                return value.toFixed(scale)
            }
            return value
        } else {
            return value
        }
    }

    const nullif = function (value, assertion) {
        if (value == assertion) {
            return null
        }
        return value;
    }

    const isnull = function (value, failover) {
        return value != null && value || failover;
    }

    const datediff = function (intervalType, first_date, last_date) {
        // Parse the input dates
        if (!(first_date && last_date)) return undefined;
        const first = new Date(first_date);
        const last = last_date.parseDate();

        // Calculate the difference in milliseconds
        const diffMs = last - first;

        // Convert milliseconds to the specified interval type
        let diffInterval;
        switch (intervalType) {
            case 'year':
                diffInterval = diffMs / (1000 * 60 * 60 * 24 * 365.25);
                break;
            case 'month':
                diffInterval = diffMs / (1000 * 60 * 60 * 24 * 30.44);
                break;
            case 'day':
                diffInterval = diffMs / (1000 * 60 * 60 * 24);
                break;
            case 'hour':
                diffInterval = diffMs / (1000 * 60 * 60);
                break;
            case 'minute':
                diffInterval = diffMs / (1000 * 60);
                break;
            case 'second':
                diffInterval = diffMs / 1000;
                break;
            default:
                throw new Error('Invalid interval type');
        }

        // Return the result rounded to 2 decimal places
        return Math.floor(Math.round(diffInterval * 100) / 100);
    }
    const year = 'year';

    if (old != value) {
        row.$$(`ancestor::px:Entity[1]/px:Record/px:Field/@formula`).map(attr => [attr.parentNode.get("Name"), attr.value.replace(/\[([^\]]+)\](\([^\)]+\))?/g, (field) => {
            let ref = attr.parentNode.parentNode.selectFirst(`px:Field[@Name="${field.substring(1, field.length - 1)}"]`);
            let formatValue = (value => {
                value = value.value || value;
                value = !ref && value || (value === null) && String(value) || value !== undefined && (isFinite(value) && value || value[0] != "'" && `'${value || ''}'`) || '';
                return value;
            });
            let value = formatValue(row.getAttribute(field.substring(1, field.length - 1)) || (ref ? (['varchar', 'nvarchar', 'date'].includes(ref.getAttribute("DataType")) ? '' : 0) : `'${field}'`));
            return value;
        })]).forEach(([key, formula]) => {
            try {
                let value = eval(formula);
                value = isFinite(value) ? value : undefined;
                row.set(key.value, [value, ''].coalesce())
            } catch (e) {
                if (e instanceof ReferenceError) {
                    Promise.reject(e)
                } else {
                    row.set(key.value, "")
                }
            }
        })
    }
})

xo.listener.on('remove::px:Entity//data:rows', function () {
    let command = this.get("command")
    let previous_parent = this.formerParentNode;
    if (!this.formerParentNode.$(`data:rows[@command="${command}"]`) && previous_parent.getAttribute(`@data:rows`) == command) {
        let data_rows = xover.xml.createNode(`<data:rows xmlns:data="http://panax.io/source"/>`);
        data_rows.reseed();
        this.formerParentNode.append(data_rows);
        data_rows.set("command", command);
    }
})

xo.listener.on('render::px:Entity', function () {
    this.select(`//*[@data:rows and not(data:rows)]`).forEach(node => node.set("data:rows", node.get("data:rows")))
})

xo.listener.on('set::@data:rows', function ({ value, old: prev }) {
    let current = this.parentNode && this.parentNode.$(`data:rows`);
    current && current.remove();
    if (!this.parentNode.$(`data:rows`)) {
        let data_rows = xover.xml.createNode(`<data:rows xmlns:data="http://panax.io/source"/>`).reseed();
        this.parentNode.append(data_rows);
        data_rows.set("command", value);
    }
})

xo.listener.on(['append::data:rows[@command]', 'set::data:rows/@command', 'remove::data:rows[not(xo:r)]/@xsi:nil'], async function ({ value, old: prev }) {
    //let current = this.parentNode && this.parentNode.$(`data:rows[@command="${prev}"]`);
    let node = this.selectFirst(`ancestor-or-self::data:rows[1]`);
    let targetNode = node
    let command = node.get("command");

    let headers = new Headers({
        "Accept": content_type.xml
    })
    let response;
    try {
        this.source && this.source.source && this.source.source.abortFetch && this.source.source.abortFetch();
        let source = xover.sources[`${node.nodeName}:=${command.value}`];
        this.source = source;
        response = await source.fetch.call(this, xover.json.tryParse(command), {
            source: node
            , method: 'GET'
            , headers: headers
        })
        node.select("*").remove({ silent: true });
        if (response instanceof Error) {
            return Promise.reject(response);
        } else if (typeof (response) === 'string') {
            return Promise.reject(new Error(response))
        } else if (!(response instanceof Document)) {
            return Promise.reject(new Error("Response is not a document"))
        } else if (!response.documentElement) {
            return Promise.reject(new Error("Response is empty"))
        }
        let new_node = response.cloneNode(true).reseed();
        new_node = new_node.documentElement;
        //let fragment = document.createDocumentFragment();
        if (new_node && (new_node.tagName == targetNode.tagName || new_node.$('self::xo:response') || ["http://www.mozilla.org/TransforMiix"].includes(new_node.namespaceURI))) {
            if (!new_node.firstElementChild) {
                targetNode.set("xsi:nil", true);
                //new_node.append(xover.xml.createNode(`<xo:empty xmlns:xo="http://panax.io/xover"/>`).reseed());
            }
        }
        new_node.selectNodes("@xo:id").remove()
        //let prev_value = targetNode.parentNode.getAttribute("prev:value");
        targetNode.disconnect();
        new_node.selectNodes('@*').forEach(attr => targetNode.setAttributeNS(attr.namespaceURI, attr.name, attr.value))
        targetNode.connect();
        targetNode.append(...new_node.childNodes);
        //let store = targetNode.store;
        /*store && store.render();*/
    } catch (e) {
        Promise.reject(e)
    }
})

//xo.listener.on('change::px:Entity/data:rows/@command', function ({ old: prev }) {
//    this.parentNode.select('xo:r').removeAll()
//    if (!this.parentNode.$('xo:r')) {
//        let data_rows = xover.xml.createNode(`<data:rows xmlns:data="http://panax.io/source"/>`);
//        data_rows.reseed();
//        data_rows.set("command", this.value);
//        this.parentNode.append(data_rows);
//    }
//})

xo.listener.on('appendTo::data:rows', function () {
    //let empty_node = node.$('xo:empty')
    //if (empty_node) {
    //    let entity = node.parentElement.$('self::px:Entity[@mode="add"][not(parent::px:Association)]')
    //    if (entity) {
    //        let fields = [...new Set(entity.$$('px:Record/px:Field|px:Record/px:Association[@Type="belongsTo"]/px:Mappings/px:Mapping|px:Record/px:Association[@Type="belongsTo"]').map(field => field.$("@Name|@Referencer").value + '=""'))].join(' ')
    //        empty_node.replace(xo.xml.createNode(`<xo:r xmlns:xo="http://panax.io/xover" ${fields}/>`))
    //    }
    //}
    if (this.$(`self::*[not(xo:r)]/xo:empty`)) {
        let entity = this.$(`ancestor::px:Entity[parent::px:Association[@Type="hasOne"]]`);
        if (entity) {
            this.append(px.createEmptyRow(entity))
        }
    }
    if (this.matches('px:Association[@DataType="junctionTable"]/px:Entity/data:rows')) {
        /*Remove mock records when there is a persisted record*/
        let referencers = (this.select(`parent::px:Entity[parent::px:Association[@DataType="junctionTable"]]/px:Record/px:Association`).filter(fks => {
            let pks = fks.select(`ancestor::px:Entity[1]/px:PrimaryKeys/px:PrimaryKey/@Field_Name`).map(pk => pk.value);
            return fks.select(`px:Mappings/px:Mapping/@Referencer`).every(referencer => pks.includes(referencer.value))
        }).map(association => association.select(`px:Mappings/px:Mapping/@Referencer`).map(referencer => referencer.value))).flat()
        let persisted_records = new Map(this.select(`../data:rows/xo:r[@meta:id!='']`).map(row => [JSON.stringify(Object.fromEntries(referencers.map(ref => [ref, row.getAttribute(ref)]))), true]));
        this.select(`../data:rows/xo:r[@meta:id='']`).filter(row => persisted_records.get(JSON.stringify(Object.fromEntries(referencers.map(ref => [ref, row.getAttribute(ref)]))))).removeAll();
    }
    this.parentNode.$$(`*[local-name()="layout"]//association:ref`).map(node => node.$(`ancestor::px:Entity[1]/px:Record/px:Association[@AssociationName="${node.get("Name")}"][not(@Type="belongsTo")]`)).filter(el => el).forEach(association => {
        //let identity_value, primary_values
        //association.$$('px:Mappings/px:Mapping').map(mapping => association.get("DataType") == 'belongsTo' && [mapping.get("Referencer"), node.get(mapping.get("Referencer"))] || mapping.get())
        if (!["belongsTo"].includes(association.getAttribute("Type"))) {
            let target_rows = this.select(`xo:r[not(px:Association[@AssociationName="${association.get("AssociationName")}"])]`);
            if (target_rows.length) {
                for (let row of target_rows) {
                    let association_copy = association.cloneNode(true);
                    //let field_association = xo.xml.createNode(`<x:f Name="${association.getAttribute("AssociationName")}"/>`)
                    association_copy.select(".//@xo:id").remove();
                    association_copy.reseed();
                    row.append(association_copy);
                    let entity = association_copy.$(`px:Entity`);
                    px.loadData(entity);
                }
            } else {
                let entity = association.$(`px:Entity`);
                px.loadData(entity);
            }
        };
        let store = this.ownerDocument.store;
        if (store && !this.selectFirst("px:Association")) {
            store.render()
        }
        //if (this.parentNode instanceof Document) {
        //    console.log(this)
        //}
    })
})

xo.listener.on(['beforeChange::@headerText', 'beforeChange::@container:*'], function ({ element, attribute, value, old }) {
    if (!element.has(`initial:${attribute.prefix && attribute.prefix + '-' || ''}${attribute.localName}`)) {
        element.set(`initial:${attribute.prefix && attribute.prefix + '-' || ''}${attribute.localName}`, old)
    }
    element.set(`prev:${attribute.prefix && attribute.prefix + '-' || ''}${attribute.localName}`, old)
    this.value = value.replace(/:/g, '').trim()
})

xo.listener.on(['set::xo:r/@state:delete'], function ({ element, attribute, value, old, event }) {
    let primary_value = px.getPrimaryValue(element);
    if (primary_value && primary_value.substr(1)) {
        event.preventDefault()
    } else {
        element.remove()
    }
})

app = {}

app.request = async function (object_name, mode) {
    let parts = object_name.split('/') || [];
    let name = parts.pop();
    let schema = parts.pop();
    return xo.sources.defaults["#" + name] || xo.xml.createDocument(`<?xml-stylesheet type="text/xsl" href="form.xslt" target="@#shell main"?><?xml-stylesheet type="text/xsl" href="shell_buttons.xslt" target="@#shell #shell_buttons" action="replace"?><${name} schema="${schema}"/>`)
}

px.getPrimaryValue = function (record, entity) {
    entity = entity || record.$(`ancestor::px:Entity[1]`)
    if (!entity) return null;
    if (entity.matches(`px:Association`)) {
        let association_ref = entity;
        let referencees = Object.fromEntries(association_ref.select('px:Mappings/px:Mapping[not(@Referencee=ancestor::px:Entity[1]/@IdentityKey)]/@Referencee').map(referencee => [referencee.value, referencee.parentNode.getAttribute("Referencer")]));
        id = entity.$$(`px:Entity/px:Record/px:Field[@IsIdentity="1"]/@Name`).map(key => record.get(referencees[key.value]));
        pks = entity.$$(`px:Entity/px:PrimaryKeys/px:PrimaryKey/@Field_Name`).map(key => record.get(referencees[key.value]));
    } else {
        id = entity.$$(`px:Record/px:Field[@IsIdentity="1"]/@Name`).map(key => record.get(key.value));
        pks = entity.$$(`px:PrimaryKeys/px:PrimaryKey/@Field_Name`).map(key => record.get(key.value));
    }
    if (id.length) {
        return ":" + id.join("/")
    } else if (pks.length) {
        return "/" + pks.join("/")
    } else {
        return ""
    }
}

px.editSelectedOption = async function (src_element) {
    let selected_record = src_element instanceof HTMLSelectElement && src_element[src_element.selectedIndex].scope.filter("self::xo:r").filter(el => el instanceof Element).pop();
    let scope = src_element.scope;
    if (!scope) {
        return Promise.reject("No hay scope asociado")
    };
    if (!selected_record) {
        return Promise.reject("No hay registro asociado")
    }
    let scope_entity = scope.parentNode.selectFirst("ancestor::px:Entity[1]");
    let selected_record_entity = selected_record.$(`ancestor::px:Entity[1]`);

    let primary_value;
    let href;
    let foreign_entity;
    if (scope_entity === selected_record_entity) {
        let association = scope.select(`ancestor::px:Entity[1]/px:Record/px:Association[@AssociationName="${scope.localName}"]`)[0];
        primary_value = px.getPrimaryValue(selected_record, association);
        foreign_entity = association.$(`px:Entity`);
    } else {
        primary_value = px.getPrimaryValue(selected_record, selected_record_entity);
        foreign_entity = selected_record_entity;
    }
    if (primary_value.substr(1)) {
        href = `#${foreign_entity.get("Schema")}/${foreign_entity.get("Name")}${primary_value}~edit`
    } else {
        return Promise.reject("No se puede editar el registro")
    }
    xo.site.seed = href
}

xo.listener.on("update::@command", function () {
    let command = xo.QUERI(this);
    return command.update();
});

xo.listener.on("downloadCatalog::xo:r/@meta:*", function () {
    let scope = this;
    let association = scope.select(`ancestor::px:Entity[1]/px:Record/px:Association[@Type="belongsTo"][@AssociationName="${scope.localName}"]`)[0];
    if (!association) return;
    let commands = association.select("data:rows/@command");
    let return_value;
    if (commands.length) {
        return_value = commands.map(command => command.update())
    } else {
        return_value = px.loadData(scope.$(`ancestor::px:Entity[1]/px:Record/px:Association[@AssociationName="${scope.localName}"]/px:Entity`))
    }
    return return_value
});

Object.defineProperty(Attr.prototype, 'schema', {
    get: function () {
        let scope = this;
        let field_name
        if (!scope) return null;
        if (scope.parentNode.matches("self::field:ref|self::association:ref")) {
            field_name = scope.value
        } else if (!scope.filter('parent::xo:r').pop()) {
            return null
        } else if (scope.namespaceURI === 'http://panax.io/metadata') {
            field_name = scope.localName
        } else {
            field_name = scope.name
        }
        if (!field_name) return null;
        return scope.selectFirst(`ancestor::px:Entity[1]/px:Record/px:*[@Name="${field_name}"]`);
    }
});

px.refreshCatalog = function (src_element) {
    src_element.scope.select(`ancestor::px:Entity[1]/px:Record/px:Association[@AssociationName="${src_element.scope.localName}"]/px:Entity/data:rows/@command`).forEach(command => command.set(command => command.value));
}

px.getEntityInfo = function (input_document) {
    var current_document = (input_document || ((event || {}).target || {}).store || xover.stores[(window.location.hash || "#")]);
    if (!current_document) return undefined;
    var entity;
    current_document = (current_document.documentElement || current_document)
    if (current_document && current_document.getAttribute && current_document.getAttribute("mode") && current_document.getAttribute("Name")) {
        entity = {}
        entity["schema"] = current_document.getAttribute("Schema");
        entity["name"] = current_document.getAttribute("Name");
        entity["mode"] = current_document.getAttribute("mode");
        entity["pageIndex"] = current_document.getAttribute("pageIndex");
        entity["pageSize"] = current_document.getAttribute("pageSize");
        entity["filters"] = (current_document.getAttribute("filters") || ''); //Se reemplazan las comillas simples por dobles comillas simples. Revisar si esto se puede hacer en px.request
    }
    return entity;
}

px.getEntityFields = function (source) {
    let fields, schema, name, mode, identity_value, primary_values, ref_node, predicate, settings = new URLSearchParams();
    if (source && typeof (source.value || source) == 'string') {
        let url = xover.URL(source);
        predicate = url.searchParams;
        fields = url.hash.replace(/^#/, '');
        if (fields.indexOf("?") != -1 && fields.indexOf("?") < fields.indexOf("#")) {
            ({ searchParams: settings, hash: fields = '' } = xover.URL(url.hash.replace(/^#/, '')));
            fields = fields.replace(/^#/, '');
        }
        let href = url.pathname.replace(/^\//, '');
        [href, mode] = href.split(/~/);
        [href, identity_value] = href.split(/:/);
        [href, ref_node] = href.split(/@/);
        [schema, name, ...primary_values] = href.split(/\//);
        settings = Object.fromEntries(settings.entries());
        predicate = Object.fromEntries(predicate.entries());
    }
    return { fields, schema, name, mode, identity_value, primary_values, ref_node, predicate, settings }
}

px.request = async function (...args) {
    let request = {};
    let fields, schema, name, mode, identity_value, primary_values, filters, settings, page_index, page_size;
    if (args.length && args[args.length - 1].constructor === {}.constructor) {
        request = Object.assign(request, args.pop());
        ({ schema, name: entity_name } = request);
    }
    let request_or_entity_name = args.pop();

    if (!request_or_entity_name) {
        return null;
    }
    if (!(xover.manifest.server["request"])) {
        throw ("Endpoint for request is not defined in the manifest");
    }
    var on_success = function (xml_document) { xover.stores.active = xml_document; };
    let rebuild;
    let prev = xo.site.history[0] || {};
    let reference = prev.reference || {};
    let ref_store = xo.stores[prev.store];
    let ref_node = ref_store && ref_store.findById(reference.id) || null;
    if (reference.id && !ref_node && reference.id == xo.QUERI(location.hash.substr(1))["ref_node"]) {
        return Promise.reject("Se perdió la referencia.")
    }
    association_ref = ref_node && ref_node.$("ancestor::px:Entity[1]/parent::px:Association")
    if (typeof (request_or_entity_name) == 'string') {
        ({
            fields, schema, name: entity_name, mode, identity_value, primary_values, ref_node, predicate: filters, headers: url_settings
        } = xo.QUERI(request_or_entity_name));
        page_size = url_settings.get("pageSize");
        page_index = url_settings.get("pageIndex");

        //request["filters"] = Object.fromEntries(url.searchParams.entries());
        //[schema, entity_name, mode = args[1]] = url.pathname.substring(1).split(/[\/~]/);
    }
    mode = (mode || request["mode"] || "view");
    page_index = request["page_index"] || page_index;
    page_size = request["page_size"] || page_size;
    filters = (request["filters"] || filters);
    on_success = (request["on_success"] || on_success);
    rebuild = request["rebuild"]

    //primary_values = primary_values.filter((item, ix) => ix % 2 != 0)
    page_size = (page_size || xover.manifest.getSettings(`#${schema}/${entity_name}~${mode}`, "pageSize").pop());
    page_index = (page_index || xover.manifest.getSettings(`#${schema}/${entity_name}~${mode}`, "pageIndex").pop());
    let mock_store = xo.Store(xo.xml.createDocument(`<entity ${xover.json.toAttributes({ filters, mode, page_size, page_index, Name: entity_name, Schema: schema })}/>`), { tag: `#${schema}/${entity_name}~${mode}`.toLowerCase() });
    let other_filters = xo.manifest.getSettings(mock_store, 'filters');
    mock_store.remove();
    filters = [...filters];
    filters = filters.concat(other_filters);
    ////if (other_filters && other_filters[0] === '`') {
    ////    let entity = { schema: schema, name: entity_name };
    ////    other_filters = eval(other_filters.replace(/\\/g, '\\\\')).replace(/\\b/g, '\\b');
    ////}
    //filters = [...Object.entries(filters), ...Object.entries(other_filters)].map(([key, value]) => `[${key}]='${value.replace(/'/g,"''")}'`).join(' AND ')+'&';
    ////filters = [filters, other_filters].filter(f => f).join(' AND ').replace(/'/g, "''");

    ////var current_location = window.location.hash.match(/#(\w+):(\w+)/);
    rebuild = ((xover.listener.keypress.altKey || xover.session.autoRebuild) ? '1' : [rebuild, 'DEFAULT'].coalesce());
    let current_store = xover.stores.active;
    current_store.state.busy = true;
    try {
        let headers = new Headers({
            "Content-Type": 'text/xml'
            , "Accept": 'text/xml'
            , "x-Detect-Input-Variables": false
            , "x-Detect-Output-Variables": false
            , "x-Debugging": xover.debug.enabled
        });
        headers = Object.fromEntries([...headers].concat(Object.entries((this.settings || {}).headers || {})));
        let Response = await xover.server.request.call(this, `command=[#entity].request @@user_id=NULL, @full_entity_name='[${schema}].[${entity_name}]', @mode=${(!mode ? 'DEFAULT' : `'${mode}'`)}, @page_index=${(page_index || 'DEFAULT')}, @page_size=${(page_size || 'DEFAULT')}, @max_records=DEFAULT, @control_type=DEFAULT, @Filters=DEFAULTS, @lang=es, @rebuild=${rebuild}, @column_list=DEFAULT, @output=HTML`, {
            headers: headers
        });
        //Request.requester = ref;
        if (!(Response instanceof xover.Store) && Response && Response.documentElement) {
            Response.$$('//px:Entity').set("meta:type", "entity")
            Response.documentElement.setAttributeNS(xover.spaces["xmlns"], "xmlns:data", "http://panax.io/source");
            association_ref && Response.documentElement.$$(`*[local-name()="layout"]/association:*[@name="${association_ref.get("AssociationName")}"]`).remove()
            px.loadData(Response.$('px:Entity'), mode == 'add' && { identity_value: null, primary_values: [null] } || { identity_value, primary_values, filters, page_size, page_index });
            //Response.documentElement.getAttributeNode('data:rows').set(value => value.replace(/\?(.*)#:=/, `?${filters || ''}&#:=`))
            return Response;
            /*
            <?xml-stylesheet type="text/xsl" href="form.xslt" target="@#shell main"?><?xml-stylesheet type="text/xsl" href="title.xslt" target="@#shell nav header h1"?><?xml-stylesheet type="text/xsl" href="shell_buttons.xslt" target="@#shell #shell_buttons" action="replace"?>
             */
            //var manifest_stylesheets = xover.manifest.getSettings(xover.data.hashTagName(xml_document.documentElement), 'transforms').filter(t => !(t.role == 'init' || t.role == "binding"));
            //var stylesheets = manifest_stylesheets.concat([{ href: (xml_document.documentElement.getAttribute('controlType') || "shell").toLowerCase() + '.xslt' }].filter(() => (manifest_stylesheets.length == 0))).reduce((stylesheets, transform) => { stylesheets.push({ "href": transform.href, target: (transform.target || '@#shell main'), role: transform.role }); return stylesheets; }, []);
            //stylesheets.forEach(stylesheet => xml_document.addStylesheet(stylesheet));
            //current_store.state.busy = undefined;
            //let store = new xover.Store(xml_document)
            //var caller = xover.stores.find(Request.requester)[0];
            //if (caller && caller.selectSingleNode('self::px:dataRow')) {
            //    var new_datarow = store.document.selectSingleNode('*/px:data/px:dataRow')
            //    if (new_datarow) {
            //        new_datarow.setAttribute('x:id', caller.getAttribute('x:id'))
            //    }
            //}
            //if (caller && caller.selectSingleNode('(ancestor-or-self::*[@Name and @Schema][1])[@foreignReference]')) {
            //    store.document.documentElement.setAttribute('x:reference', caller.getAttribute('x:id'), false)
            //    var foreignReference = caller.selectSingleNode('ancestor-or-self::*[@foreignReference]');
            //    if (foreignReference) {
            //        store.documentElement.selectNodes('//px:layout//px:field[@fieldName="' + foreignReference.getAttribute('foreignReference') + '"]').remove(false);
            //    }
            //}
            //store.addStylesheet({ href: 'xover/panax/panax_bindings.xslt', target: 'self', action: 'replace' });
            //store.initialize();
            //xover.stores.active = store;
        }
    } catch (e) {
        current_store.state.busy = undefined;
        if (e.document instanceof HTMLDocument) {
            return Promise.reject(xover.dom.createDialog(e.document));
        } else {
            return Promise.reject(e);
        }
    }
}

xo.listener.on('fetch::px:Entity', function () {
    let entity = this;
    let prev = xo.site.history[0] || {};
    let reference = prev.reference || {};
    let ref_store = xo.stores[prev.store];
    let ref_node = ref_store && ref_store.findById(reference.id) || null;
    ref_node && ref_node.$$('ancestor::px:Association[1]').map(el => entity.$(`px:Entity/*[local-name()="layout"]/association:ref[@Name="${el.get("AssociationName")}"]`)).forEach(el => el && el.remove())

    entity.$$('px:Entity/px:Record/px:Field[@mode="hidden"]').map(el => entity.$(`px:Entity/*[local-name()="layout"]/field:ref[@Name="${el.get("Name")}"]`)).forEach(el => el && el.remove())

    // Quitamos rutas de los datagrids hijos de datagrids
    entity.select(`//px:Entity[@control:type="datagrid:control"]/px:Record/px:Association/px:Entity[@control:type="datagrid:control"]/px:Routes/px:Route`).remove()

    // Quitamos las rutas que no tienen ni Identity ni Primary
    let routes = entity.$$(`//px:Entity[not(@IdentityKey) and not(px:PrimaryKeys/px:PrimaryKey)]/px:Routes/px:Route[@Method="add" or @Method="edit" or @Method="delete"]`);
    routes.remove();
})

xo.listener.on('fetch::px:Entity[not(//processing-instruction())]', function ({ document }) {
    //this.replaceBy(this.transform("xover/databind.xslt"))
    //let control_type = (document.$('//px:Entity').getAttribute("xsi:type") || '').replace(':control', '.xslt')
    document.addStylesheet({ href: "px-Entity.xslt", target: "@#shell main" });
})

px.setAttributes = function (target, attribute, value) {
    let attributes = attribute.split("/")
    let values = value.split("/")
    let entries = []
    for (let i = 0; i < attributes.length; ++i) {
        entries.push([attributes[i], values[i]])
    }
    target.setAttributes(Object.fromEntries(entries))
}

px.loadData = function (entity, keys) {
    let returnValue = [];
    if (!(entity instanceof Node)) return;
    if (entity.matches("/px:Entity")) {
        let prev = xo.site.history[0] || {};
        let reference = prev.reference || {};
        let ref_store = xo.stores[prev.store];
        let ref_node = ref_store && ref_store.findById(reference.id) || null;
        if (ref_node && reference.id == xo.QUERI(location.hash.substr(1))["ref_node"] && ref_node.matches("xo:r")) {
            let data_rows = entity.$("data:rows") || entity.createNode(`<data:rows xmlns:data="${ref_node.resolveNS("data")}"/>`)
            data_rows.append(ref_node.cloneNode(true))
            return;
        }
    }
    if (entity.$('data:rows')) return;
    keys = Object.assign({ identity_value: undefined, primary_values: [] }, keys);
    let id = entity.$$(`px:Record/px:Field[@IsIdentity="1"]/@Name`).map(key => [key, keys.identity_value]);
    let pks = entity.$$(`px:PrimaryKeys/px:PrimaryKey/@Field_Name`).map((key, ix) => [key, keys.primary_values[ix]]);
    let filters = keys["filters"] || [];
    let page_size = keys["page_size"];
    let page_index = keys["page_index"];
    constraints = [...id, ...pks]

    let fields = Object.fromEntries(constraints.map(([key]) => key).concat(entity.$$('@custom:*|px:Record/px:Field/@Name|px:Record/px:Association[@Type="belongsTo"]/px:Mappings/px:Mapping/@Referencer|px:Record/px:Association[@Type="belongsTo"]/@Name')).map(field => field.prefix == 'custom' ? [`${field.nodeName}`, field.value] : [`${field.parentNode.nodeName == 'px:Association' && 'meta:' || ''}${field.value}`, `#panax.${field.parentNode.$("self::*[@DataType='nvarchar' or @DataType='varchar' or @DataType='foreignKey' or @DataType='files']") ? 'prepareString' : (field.parentNode.$("self::*[@DataType='xml']") ? 'prepareXML' : 'prepareValue')}(` + (field.parentNode.$("self::px:Association") && `(SELECT ${field.parentNode.$("px:Entity/@displayText|px:Entity[not(@displayText)]/@combobox:text").value} FROM [${field.parentNode.$("px:Entity/@Schema").value}].[${field.parentNode.$("px:Entity/@Name").value}] #foreign WHERE ${field.parentNode.$$('px:Mappings/px:Mapping').map(map => '[' + entity.get("Name") + '].[' + map.get("Referencer") + '] = #foreign.[' + map.get("Referencee") + ']').join(' AND ')})` || `[${field.value}]`) + ')']))

    function getText(entity, entity_name) {
        let text = entity.$$(`@displayText|self::*[not(@displayText)]/@combobox:text|px:Record/px:Field[not(@IsIdentity="1" or @DataType="xml")][1]/@Name|px:Record[not(*[2])]/px:Field[not(@DataType="xml")]/@Name`).shift();
        if (text) {
            return text.matches('@Name') && `RTRIM(#panax.${text.parentNode.getAttribute("DataType") == 'xml' && 'prepareXML' || 'prepareString'}([${entity_name}].[${text.value}]))` || text.value; // No se ponen brackets para los nombres de las funciones
        }
    }

    fields["meta:text"] = getText(entity, entity.getAttribute("Name"));
    //if (id.length) {
    fields["meta:id"] = id.map(el => `#panax.prepareValue([${el[0]}])`).join("+'/'+");
    //} else {
    //let mappings = entity.$$("ancestor::px:Association[1][@Type='belongsTo']/px:Mappings/px:Mapping/@Referencee")
    fields["meta:value"] = pks.map(el => `RTRIM(#panax.prepareString([${el[0]}]))`).join("+'/'+");
    //}
    let order_by = px.buildSortSentence(entity);

    let formatValue = (value => (value === null) && String(value) || value !== undefined && value[0] != "'" && `'${value}'` || value || '');
    let formatKey = ((entity) => (key => key instanceof Attr && `[${key.value}]` || key.indexOf("`") != -1 && eval(key.replace(/\\/g, '\\\\')).replace(/\\b/g, '\\b') || `[${key}]`))({ schema: entity.getAttribute("Schema"), name: entity.getAttribute("Name") });
    constraints = constraints.concat([...filters]);

    let predicate = constraints.filter(([, value]) => value !== undefined).map(([key, value]) => (key instanceof Attr || value) && ['WHERE', `${formatKey(key)} IN (${(value instanceof Array) ? value.map(item => formatValue(item)) : formatValue(value)})`] || key.indexOf("`") != -1 && formatKey(key) || key);
    let parent_row = entity.$('ancestor::xo:r[1]');
    if (parent_row) {
        let parent_relationship = entity.$('parent::px:Association[not(@Type="belongsTo")]/px:Mappings')
        let mappings = parent_relationship && parent_relationship.$$('px:Mapping').map(map => ['WHERE', `[${entity.get("Name")}].[${map.get("Referencer")}] IN ('${parent_row.get(map.get("Referencee")) || 'NULL'}')`]) || [];
        predicate = predicate.concat(mappings)
    }
    let data_rows = xo.xml.createNode(`<data:rows xmlns:data="http://panax.io/source"/>`);
    returnValue.push(data_rows);
    entity.append(data_rows);
    data_rows.setAttribute("command", `${entity.get("Schema")}/${entity.get("Name")}?${new URLSearchParams(predicate || {})}#?&pageIndex=${page_index || 1}&pageSize=${page_size || (parent_row ? '100' : '1000')}&orderBy=${order_by}&fields=${encodeURIComponent(Object.entries(fields).filter(([, value]) => value).sort((first, second) => first[1].indexOf("XML") - second[1].indexOf("XML")).map(([key, value]) => `[${value.indexOf("prepareXML") == -1 ? '@' + key : "x:f/@Name]='" + key + "', [x:f"}]=${value.replace(/#panax\.prepareXML/, '')}`).join('&'))}`)
    let junction_association = entity.select(`self::px:Entity[parent::px:Association[@DataType="junctionTable"]]/px:Record/px:Association`).filter(fks => {
        let pks = fks.select(`ancestor::px:Entity[1]/px:PrimaryKeys/px:PrimaryKey/@Field_Name`).map(pk => pk.value);
        return fks.select(`px:Mappings/px:Mapping/@Referencer`).every(referencer => pks.includes(referencer.value))
    });
    for (let association of junction_association) {
        let associated_entity = association.selectFirst("px:Entity");
        px.loadData(associated_entity);
    }
    //if (junction_association.length) {
    //    let data_rows_complement = data_rows.cloneNode(true).reseed(true);
    //    let command = xo.QUERI(data_rows_complement.get("command"));
    //    command.pathname = '';
    //    command.predicate.delete('WHERE');
    //    id.map(([el]) => command.fields[`[@${el.value}]`] = `#panax.prepareValue(NULL)`);
    //    [...Object.entries(command.fields)].map(([el]) => command.fields[el] = `#panax.prepareValue(NULL)`);
    //    let mappings = entity.parentNode.select('px:Mappings/px:Mapping');
    //    for (let mapping of mappings) {
    //        let referencer = mapping.getAttribute("Referencer");
    //        let referencee = mapping.getAttribute("Referencee");
    //        command.fields[`[@${referencer}]`] = parent_row.getAttribute(referencee) || null
    //    }
    //    for (let association of junction_association) {
    //        let associated_entity = association.selectFirst("px:Entity");
    //        let table_name = associated_entity.getAttribute("Name");
    //        command.predicate.append('FROM',
    //            [associated_entity].reduce((name, entity) => `[${entity.getAttribute("Schema")}].[${entity.getAttribute("Name")}]`, ''))
    //        command.fields[`[@meta:${association.getAttribute("AssociationName")}]`] = getText(associated_entity, table_name);
    //        for (let mapping of association.select('px:Mappings/px:Mapping')) {
    //            let referencer = mapping.getAttribute("Referencer");
    //            let referencee = mapping.getAttribute("Referencee");
    //            for (let curr_association of junction_association.filter(curr_association => curr_association != association)) {
    //                let curr_entity = curr_association.selectFirst("px:Entity/@Name");
    //                for (let matching_mapping of curr_association.select(`px:Mappings/px:Mapping[@Referencer="${referencer}"]`)) {
    //                    command.predicate.append('WHERE', `[${table_name}].[${referencee}] = [${curr_entity.value}].[${matching_mapping.getAttribute("Referencee")}]`)
    //                }
    //            }
    //            if (mappings.find(mapping => mapping.getAttribute("Referencer") == referencer)) {
    //                command.predicate.append('WHERE', `[${table_name}].[${referencee}] = '${parent_row.getAttribute(referencer)}'`)
    //            }
    //            command.fields[`[@${referencer}]`] = `#panax.prepareValue([${table_name}].[${referencee}])`
    //        }
    //    }
    //    command.fields['[@meta:value]'] = '#panax.prepareValue(NULL)';
    //    command.fields['[@meta:id]'] = '#panax.prepareValue(NULL)';
    //    command.fields['[@meta:text]'] = '#panax.prepareString(NULL)';
    //    command.update();
    //    data_rows_complement.set("xsi:type", "mock")
    //    returnValue.push(data_rows_complement);
    //    entity.append(data_rows_complement);
    //}
    return returnValue;
}

px.buildSortSentence = function (entity) {
    if (!entity) return '';
    function formatName(node, quoteChar = '"') {
        let str = node.select("../@Name").map(name => name.matches("px:Association/@Name") && `@meta:${name}` || `@${name}`).pop();
        return quoteChar + str.replace(quoteChar, quoteChar + quoteChar) + quoteChar;
    }
    return entity.getAttribute("custom:sortBy") || entity.select("px:Record/*/@sortOrder").sort((a, b) => {
        const orderA = parseInt(a.value);
        const orderB = parseInt(b.value);
        return orderA - orderB;
    }).map(attr => formatName(attr) + (' ' + (attr.parentNode.getAttribute("sortDirection") || '')).trimEnd()).join(",")
}

xo.listener.on([`change::px:Record/px:*/@sortOrder`, `change::px:Record/px:*/@sortDirection`], function ({ old, value }) {
    if (xover.listener.keypress.ctrlKey) {
        let attrs = this.parentNode.select('@sortOrder|@sortDirection');
        if (this.matches('@sortDirection[.!=""]')) {
            attrs.remove()
        }
    } else if (old === null) {
        this.select('ancestor::px:Record[1]/*/@sortOrder|ancestor::px:Record[1]/*/@sortDirection').filter(sorter => sorter.parentNode !== this.parentNode).remove()
    }
    for (let command of this.select(`ancestor::px:Entity[1]/data:rows/@command`)) {
        qri = xo.QUERI(command)
        qri.headers.set("orderBy", px.buildSortSentence(this.selectFirst('ancestor::px:Entity[1]')));
        qri.update()
    }
})

xo.listener.on(`change::px:Record/px:*[not(@sortOrder)]/@sortDirection`, function ({ element }) {
    let sortOrder = element.select('parent::px:Record[1]/*/@sortOrder').sort((a, b) => {
        const orderA = parseInt(a.value);
        const orderB = parseInt(b.value);
        return orderA - orderB;
    }).map(el => +el.value).pop() || 0;
    element.setAttribute("sortOrder", sortOrder + 1);
})

xo.listener.on(`filter::@*`, function ({ event }) {
    if ((event.srcEvent || event).ctrlKey && this.ownerElement) {
        this.remove();
        return;
    }
    filters = prompt(`Filtrar por ${this.parentNode.getAttribute("headerText") || this.parentNode.getAttribute("Name")}`);
    if (!filters) filters = null;
    if (this.matches(`px:Association[@DataType="junctionTable"]/px:Entity/px:Record/px:Association/@*`)) {
        this.parentNode.select(`px:Entity/data:rows`).forEach(entity => entity.setAttribute(this.nodeName, filters))
    } else {
        this.set(filters);
    }
})

xo.listener.on('change::@state:filter', function ({ target, stylesheet }) {
    function formatName(node, quoteChar = '"') {
        let str = node.select("../@Name|../self::data:rows").map(name => name.matches("data:rows") ? '@meta:text' : name.matches("px:Association/@Name") && `@meta:${name}` || `@${name}`).pop();
        return quoteChar + str.replace(quoteChar, quoteChar + quoteChar) + quoteChar;
    }

    let commands;
    if (this.matches(`px:Association[@DataType="junctionTable"]/px:Entity/px:Record/px:Association/@*`)) {
        commands = this.parentNode.select(`px:Entity[1]/data:rows/@command`)
    } else {
        commands = this.parentNode.select(`ancestor-or-self::px:Entity[1]/data:rows/@command`)
    }

    for (let command of commands) {
        qri = xo.QUERI(command)
        let predicate = qri.predicate;
        predicate.delete('AND');
        for (let filter of command.parentNode.select('@state:filter|ancestor-or-self::px:Entity[1]/px:Record/*/@state:filter')) {
            predicate.append('AND', `${formatName(filter)} LIKE '%${(filter.value || '').replace(/'/g, "''")}%' COLLATE Latin1_General_CI_AI`);
        }
        qri.headers.set("pageIndex", 1);
        qri.update()
    }
})

px.getData = async function (...args) {
    let settings = args.pop() || {};
    let parameters = args.pop() || {};
    let node = settings["source"];
    if (node) {
        let command = parameters;
        let attribute_base_name = node.localName;
        let fields, request = '', predicate = {}, url_settings;
        if (parameters && typeof (parameters.value || parameters) === 'string') {
            ({
                fields, schema, name, mode, identity_value, primary_values, predicate, headers: url_settings
            } = xo.QUERI(parameters));
            page_size = url_settings.get("pageSize");
            page_index = url_settings.get("pageIndex");
            order_by = url_settings.get("orderBy");
            if (name) {
                request = `[${name}]`
                if (schema) {
                    request = `[${schema}].${request}`
                }
            }
            ////let [request_with_fields, ...predicate] = command.split(/=>|&filters=/);
            ////let [fields, request] = comnd.match('(?:(.*)~>)?(.+)');
            //[rest, page] = parameters.indexOf("#:=") != -1 && parameters.split("#:=") || [parameters, "1/20"];
            //[rest, predicate = ''] = rest.split("=>");
            //[fields, request] = rest.indexOf("~>") != -1 && rest.split("~>") || ["*", rest];
            ////let [, fields, request, predicate = ''] = command.match('(?:(.*)~>|^)?((?:(?<!=>).)+)(?:=>(.+))?$');

            //parameters = (node.getAttribute('source_filters:' + attribute_base_name) || predicate || "");
            //let params = Object.fromEntries([...predicate.entries()].filter(([key, value]) => key[0] == '@'));
            /*predicate = ([...predicate.entries()].filter(([key, value]) => key[0] != '@').map(([key, value]) => value === undefined && key || key.toUpperCase() == 'AND' && (value || '') || `${key[0] == '[' && key || `[${key}]`}='${(value || '').replace(/'/g, "''")}'`)).join(' AND ');*/
            parameters = new URLSearchParams([...predicate.entries()].filter(([key]) => key).map(([key, value]) => !value && !key.match(/^\[[^\]]+\]|\w+/g) && ['WHERE', key] ||
                key.match(/^\[[^\]]+\]|\w+/) && [key, (value || '')]));


            let search_params = {};
            if (request) {
                parameters.append("FROM", request)
            }
            //if (predicate) {
            //    search_params["predicate"] = predicate
            //}
            //Object.entries(params).forEach(([key, value]) => parameters.append(key, value))
        }
        let root_node = node.prefix.replace(/^request$/, "source") + ":" + attribute_base_name;
        //

        let headers = new Headers(xover.json.merge(settings["headers"] instanceof Headers && Object.fromEntries(settings["headers"].entries()), {
            "Cache-Response": (node.parentNode && Array.prototype.coalesce(eval(node.getAttribute("cache" + ":" + (attribute_base_name))), eval(node.parentNode && node.parentNode instanceof Element && node.parentNode.getAttribute("cache" + ":" + (attribute_base_name))), false))
            , "Accept": content_type.xml
            , "cache-control": 'max-age=0'
            /*, "pragma": 'force-cache'*/
            , "x-original-request": command
            , "x-namespaces": `'${node.resolveNS(node.prefix)}' as ${node.prefix}`
            , "x-Root-Node": root_node
            , "x-Page-Index": (page_index || '')
            , "x-Page-Size": (page_size || '')
            , "x-Detect-Missing-Variables": "false"
            , "x-Debugging": xover.debug.enabled
            , "x-data-text": encodeURIComponent(node.getAttribute('source_text:' + attribute_base_name) || node.getAttribute('dataText') || "")
            , "x-data-value": encodeURIComponent(node.getAttribute('source_value:' + attribute_base_name) || node.getAttribute('dataValue') || "")
            , "x-data-fields": (fields.toString().replace(/&/g, ',') || "")
            , "x-order-by": order_by || ""
        }))
        settings["headers"] = headers;
    }
    args.push(parameters);
    args.push(settings);
    try {
        let response = await xo.server.request.apply(this, args);
        if (!(node && node.parentElement)) return;
        let entity = node.parentElement.$('self::px:Entity[ancestor-or-self::*[@mode="add"] and not(parent::px:Association[@Type="hasMany"]) or parent::px:Association[@Type="hasOne"]]');
        //let entity = node.$('parent::px:Entity[//px:Entity[@mode="add"]]')
        if (entity && !(response.documentElement.firstElementChild)) {
            response.documentElement.append(px.createEmptyRow(entity))
        }
        if (node.$('self::*[not(@xsi:type="mock")]/parent::px:Entity/parent::px:Association[@DataType="junctionTable"]')) {
            response.documentElement.select(`xo:r`).forEach(row => row.set("state:checked", "true"))
        }
        return response
    } catch (e) {
        return Promise.reject(e)
    }
}

px.applyFilters = function (attribute_node) {
    let command = xo.QUERI(attribute_node);
    attribute_node.select("ancestor::px:Entity/px:Parameters//px:Parameter").forEach(param => {
        command.predicate.set(param.getAttribute("parameterName"), param.getAttribute("value") || "null")
    })
    command.update()
}

px.createEmptyRow = function (entity) {
    let fields = [...new Set(entity.$$('px:Record/px:Field/@Name|px:Record/px:Association[@Type="belongsTo"]/px:Mappings/px:Mapping/@Referencer|px:Record/px:Association[@Type="belongsTo"]/@Name').map(field => ((field.parentNode.nodeName == 'px:Association' ? 'meta:' : '') + field.value) + '=""'))].join(' ')
    return xo.xml.createNode(`<xo:r xmlns:xo="http://panax.io/xover" xmlns:state="http://panax.io/state" xsi:type="mock" state:new="true" ${fields}/>`).reseed();
}

xover.listener.on('click::a', async function (event) {
    let href = this.getAttribute("href") || '';
    if (href.length > 1 && href.indexOf("#") != -1) {
        event.preventDefault();
        px.navigateTo(href, this.scope);
    }
})

px.navigateTo = function (hashtag, ref_id) {
    let scope = event.srcElement.scope;
    ref_id = ref_id || (scope && scope.$("data:rows/@xo:id") || {}).value;
    hashtag = (hashtag || "").replace(/^([^#])/, '#$1');
    let store = xo.stores[hashtag];
    store && store.remove();
    if ([xo.site.seed, ...(xo.site.activeTags() || [])].includes(hashtag) || xover.stores[hashtag].isRendered) { //TODO: Revisar si isRendered siempre 
        xo.site.active = hashtag;
    } else {
        xo.site.next = hashtag;
        xo.site.seed = hashtag;
    }
    xover.stores.active.render();
}

function saveConfiguration() {
    xo.stores.active.documentElement.$$('//px:Record/*/@prev:*').map(attr => [`[${attr.parentNode.$('ancestor::px:Entity[1]').get('Schema')}].[${attr.parentNode.$('ancestor::px:Entity[1]').get('Name')}]`, (attr.parentNode.get("AssociationName") || attr.parentNode.get("Name")), `@${attr.localName.replace('-', ':')}`, attr.parentNode.get(attr.localName.replace('-', ':'))]).map(el => el.map(item => `'${item}'`)).forEach(config => xo.server.request({ command: "[#entity].[config]", parameters: config }, {}).then(response => response.render && response.render()))
}

xo.spaces["post"] = "http://panax.io/persistence";

px.submit = async function (data_rows = xo.stores.active.select(`/px:Entity/data:rows/xo:r`)) {
    data_rows = data_rows instanceof Array ? data_rows : [data_rows];
    function buildPost(data_rows, target = xo.xml.createNode(`<batch xmlns="http://panax.io/persistence" xmlns:state="http://panax.io/state" xmlns:session="http://panax.io/session"/>`)) {
        data_rows.reduce((entities, row) => {
            let entity = row.$('ancestor-or-self::px:Entity[1]');
            !entities.includes(entity) && entities.push(entity);
            return entities;
        }, []).forEach(entity => {
            let id = entity.$(`px:Record/px:Field[@IsIdentity="1"]`)
            let dataTable = xo.xml.createNode(`<dataTable xmlns="http://panax.io/persistence" name="[${entity.get("Schema")}].[${entity.get("Name")}]"${id ? ` identityKey="${id.get("Name")}"` : ''}/>`)
            target.append(dataTable)
        });
        for (let row of data_rows) {
            let entity = row.$('ancestor-or-self::px:Entity[1]');
            let id = entity.get('IdentityKey');
            let primary_fields = entity.select("px:PrimaryKeys/px:PrimaryKey/@Field_Name");
            let dataTable = target.selectFirst(`*[contains(@name,"[${entity.get("Schema")}].[${entity.get("Name")}]")]`);
            let mappings = row.$$("ancestor::px:Association[1]/px:Mappings/px:Mapping/@Referencer");
            let dataRow;
            if (row.$('self::*[@state:delete]')) {
                dataRow = xo.xml.createNode(`<deleteRow xmlns="http://panax.io/persistence"${id ? ` identityValue="${row.get(id.value)}"` : ''}/>`);
                !id && entity.$$('px:Record/px:Field/@Name').filter(field => primary_fields.find(el => el.value == field.value))/*.filter(field => !mappings.find(mapping => mapping.value == field.value))*/.forEach(field => {
                    let current_value = row.get(`${field}`);
                    let field_node = xo.xml.createNode(`<field xmlns="http://panax.io/persistence" name="${field}" currentValue="'${row.get(`initial:${field}`) || current_value}'" isPK="true"/>`);
                    dataRow.append(field_node);
                })
            } else {
                let id_node = row.get(`${id}`)
                if (id_node ? id_node.value : primary_fields.filter(field => {
                    let initial = row.get(`initial:${field}`);
                    let value = row.getAttribute(field.value);
                    return value && initial == undefined || initial && initial.value && initial.value != value || false;
                }).length) {
                    dataRow = xo.xml.createNode(`<updateRow xmlns="http://panax.io/persistence"${id ? ` identityValue="${row.get(id.value)}"` : ''}/>`);
                    entity.$$('px:Record/px:Field[not(@IsIdentity="1" or @formula or @mode="readonly")]/@Name').filter(field => !mappings.find(mapping => mapping.value == field.value)).forEach(field => {
                        let isPK = field.$(`ancestor::px:Entity[1]/px:PrimaryKeys/px:PrimaryKey[@Field_Name="${field}"]`)
                        let field_node = xo.xml.createNode(`<field xmlns="http://panax.io/persistence" name="${field}"${isPK ? ` isPK="true"` : ''}/>`);
                        let current_value = (row.get(`${field}`) || {}).value;
                        current_value = !isNaN(Number(current_value)) ? Number(current_value) : current_value;
                        let initial_value = row.get(`initial:${field}`);
                        initial_value = initial_value ? initial_value.value : current_value;
                        initial_value = !isNaN(Number(current_value)) ? Number(initial_value) : initial_value;
                        let changed = initial_value != current_value;
                        if (isPK || changed) {
                            let confirmation = row.get(`confirmation:${field}`);
                            if (confirmation && confirmation != current_value) {
                                field_node.set(`exception:message`, `El valor de ${field} debe ser confirmado`)
                                row.set(`exception:${field}`, "")
                            }
                            field_node.set("currentValue", `'${row.get(`initial:${field}`) || row.get(field.value)}'`);
                            field_node.textContent = [row.get(field.value)].map(val => !val.value && (field.$("../@defaultValue") || 'null') || `'${val}'`);
                            dataRow.append(field_node);
                        }
                    })
                } else {
                    dataRow = xo.xml.createNode(`<insertRow xmlns="http://panax.io/persistence"/>`);
                    entity.$$('px:Record/px:Field[not(@IsIdentity="1" or @formula or @mode="readonly")]/@Name').filter(field => !mappings.find(mapping => mapping.value == field.value)).forEach(field => {
                        let isPK = field.$(`ancestor::px:Entity[1]/px:PrimaryKeys/px:PrimaryKey[@Field_Name="${field}"]`);
                        let field_node = xo.xml.createNode(`<field xmlns="http://panax.io/persistence" name="${field}"${isPK ? ` isPK="true"` : ''}/>`);
                        field_node.textContent = [row.get(field.value)].map(val => !val.value && (field.$("../@defaultValue") || 'null') || `'${val}'`);
                        dataRow.append(field_node);
                    })
                }
            }
            mappings.forEach(mapping => dataRow.nodeName != 'deleteRow' && dataRow.insertFirst(xo.xml.createNode(`<fkey xmlns="http://panax.io/persistence" name="${mapping}" maps="${mapping.$("../@Referencee")}"/>`)))
            dataTable.append(dataRow);
            row.select(`px:Association[not(@Type="belongsTo")]/px:Entity`).forEach(foreign_entity => {
                return buildPost(foreign_entity.$$('data:rows[not(@xsi:type="mock")]/xo:r[not(@xsi:type="mock")]'), dataRow)
            })
        }
        return target;
    }
    let prev = xo.site.history[0] || {};
    let reference = prev.reference || {};
    let ref_store = xo.stores[prev.store];
    let ref_node = ref_store && ref_store.findById(reference.id) || null;
    if (ref_node && reference.id == xo.QUERI(location.hash.substr(1))["ref_node"]) {
        if (ref_node.matches("xo:r")) {
            ref_node.replaceWith(data_rows[0])
        } else if (ref_node.matches("data:rows")) {
            ref_node.selectFirst("ancestor::px:Entity[1]/px:Record").replaceWith(data_rows[0].selectFirst("ancestor::px:Entity[1]/px:Record").cloneNode(true));
            ref_node.append(...data_rows)
        }
        let srcElement = event.srcElement;
        let interface = srcElement && srcElement.closest("[role='alertdialog']") || xo.stores.active;
        interface.remove();
        return;
    }
    //if (ref_node && ref_node.$('ancestor::px:Association')) {
    //    ref_node.selectFirst("ancestor::px:Entity[1]/px:Record").replaceWith(data_rows[0].selectFirst("ancestor::px:Entity[1]/px:Record").cloneNode(true));
    //    ref_node.append(...data_rows);
    //    xo.stores.active.remove();
    //    return
    //}
    for (let row of data_rows) {
        let pending = [];
        row.select(".//@*[contains(.,'blob:')]").filter(node => node && (!node.namespaceURI || node.namespaceURI.indexOf('http://panax.io/state') == -1)).map(node => { pending.push(xover.server.uploadFile(node)) })
        await Promise.all(pending);

        let post = buildPost([row]);
        post.select(`//post:dataTable/post:updateRow[not(post:field or post:dataTable)]`).remove();
        post.select(`//post:dataTable[not(post:*)]`).remove();
        let messages = post.select("//@exception:message").map(el => document.createElement('li').set(new Text(el.value)));
        if (messages.length) {
            let list = document.createElement("ul");
            list.append(...messages);
            xo.dom.alert(list)
            return;
        }
        try {
            window.top.dispatchEvent(new xover.listener.Event('beforeSubmit', { post: post }, row));
        } catch (e) {
            return Promise.reject(e);
        }
        row.setAttribute("xmlns:session", "http://panax.io/session")
        post.setAttribute("xmlns:session", "http://panax.io/session")
        post = xo.xml.normalizeNamespaces(post).documentElement;
        payload = xover.xml.createDocument(`<x:post xmlns:x="http://panax.io/xover" xmlns:session="http://panax.io/session"><x:source/><x:submit/></x:post>`);
        payload.documentElement.$("xo:source").append(row.cloneNode(true));
        payload.documentElement.$("xo:submit").append(post);
        let loading = xo.sources["loading.xslt"].render()
        Object.defineProperty(payload, 'scope', { value: row })
        xover.server.submit(payload, (return_value, request, response) => [return_value, request, response]).catch(result => {
            let result_document = result.document
            if (result_document instanceof Document) {
                result_document.$$('//result[not(//processing-instruction())][@status="error"]/@statusMessage').forEach(el => el.render())
                if (result_document.documentElement) {
                    result_document.render()
                }
            } else if (result_document && result_document.render) {
                result_document.render()
            } else if (result.render) {
                result.render();
            } else {
                throw (result);
            }
        }).finally(() => {
            loading.then(el => el.flat(Infinity).removeAll());
        })
    }
}

xo.listener.on(['response::xo:prompt'], function ({ response_value }) {
    let response = this;
    new xo.Store(response.document, { tag: "#prompt" });
})

xo.listener.on('success::#server:submit', function ({ request, payload }) {
    let prev = xo.site.history[0] || {};
    let reference = prev.reference || {};
    let ref_store = xo.stores[prev.store];
    let ref_node = ref_store && ref_store.findById(reference.id) || null;
    ref_node = reference.attribute && ref_node && ref_node.getAttributeNode(reference.attribute) || ref_node;
    if (reference.id && !ref_node && reference.id == xo.QUERI(location.hash.substr(1))["ref_node"]) {
        return Promise.reject("Se perdió la referencia.")
    }
    let result = this.document;
    let scope = ((request.settings || {})["body"] || {})["scope"];
    if (!(result instanceof Node)) return;
    if (result.$$('//result').length && result.$$('//result').every(r => r.get("status") == 'success')) {
        let entity = scope.$("ancestor-or-self::px:Entity[last()]");
        if (!entity) return;
        if ((entity.getAttribute("control:type") || '').indexOf('form') != -1) {
            let [entity_schema, entity_name] = [entity.getAttribute("Schema"), entity.getAttribute("Name")];
            if (ref_node instanceof Attr) {
                ref_node.parentNode.select(`ancestor-or-self::px:Entity[1]/px:Record/px:Association[@Type="belongsTo"][@AssociationName="${ref_node.localName}"]/px:Entity/data:rows/@command`).set(command => command.value);
            } else {
                ref_node && ref_node.parentNode.select("(ancestor-or-self::px:Entity[1]/data:rows/@command|ancestor-or-self::data:rows[1]/@command)[last()]").set(value => value);
            }
            entity.ownerDocument.store.remove();
            ref_store && ref_store.select(`//px:Entity[@Schema="${entity_schema}" and @Name="${entity_name}"]/data:rows/@command`).forEach(attr => attr.set(attr.value));
            xo.site.set("dirty", Object.fromEntries([["Schema", entity_schema], ["Name", entity_name]]))
        } else {
            entity.$$('//data:rows/@command').forEach(command => xo.QUERI(command).update())
        }
        return;
    }

    result.$$('//result').forEach(result => {
        if (["error", "exception"].includes(result.get("status"))) {
            scope.set("state:message", result.get("statusMessage"))
        } else {
            if (scope.get("state:delete")) {
                scope.remove()
            }
        }
    })
})

xo.listener.on(['failure::#server:submit', 'failure::#server:request'], function ({ payload }) {
    if (!this.document) return;

    this.document.$$('//result[@status="error"]/@statusMessage|xo:message/text()').set(message => {
        let document = message.ownerDocument;
        let [match, action, type, constraint_name, table, column] = [...message.value.matchAll(/^.*(INSERT|UPDATE|DELETE).*(REFERENCE|FOREIGN KEY)\s'([^']+)'.*, tabl[ae]\s'([^']+)'(?:, column '([^']+)')?/g)][0] || [];
        if (match) {
            document.addStylesheet({ href: 'message.constraints.xslt', role: 'alertdialog' })
            message.parentNode.setAttributes({ action, type, constraint_name, column })
            let [schema, table_name] = table.split(".");
            message.parentNode.setAttributes({ schema, table_name });
            if (action == 'DELETE') {
                let references = payload.select("/x:post/x:submit/post:batch/post:dataTable/post:deleteRow/@identityValue").map(identity => identity.value);
                let [schema, table_name] = table.split(".")
                if (references.length) {
                    message.parentNode.setAttributes({ schema, table_name });
                    message.parentNode.setAttribute("reference", references.join(","));
                }
                return `No se puede eliminar el registro porque está en uso en el módulo ${table_name} (${schema}).`
            } else if (action == 'UPDATE') {
                let association = xo.stores.active.selectFirst(`//px:Association[@AssociationName="${constraint_name}"]`);
                if (association) {
                    let header_text = association.getAttribute("headerText");
                    let related_entity = association.selectFirst("px:Entity/@headerText");
                    return `El valor asignado en "${header_text}" sólo permite elementos existentes en el módulo ${related_entity}.`
                }
            }
        }
        return message.value;
    })
})

//xover.listener.on('hashchange', function (new_hash, old_hash) {
//    let dirty_entity = xover.site.get("dirty");
//    //xo.stores.active.select(`//px:Entity/data:rows/@xsi:nil|//px:Entity/data:rows[not(*)]|//px:Entity[@Schema="${dirty_entity["Schema"]}" and @Name="${dirty_entity["Name"]}"]/data:rows`).remove();
//    xo.stores.active.select(`//px:Entity[@Schema="${dirty_entity["Schema"]}" and @Name="${dirty_entity["Name"]}"]/data:rows/@command`).forEach(attr => attr.set(attr.value));
//    ////xo.stores.active.select(`//px:Entity/data:rows/@xsi:nil`).remove();
//    ////xo.stores.active.select('//px:Entity[@data:rows][not(data:rows)]').set("data:rows", ({ el }) => el.get("data:rows"));
//    //xover.site.set("dirty", undefined)
//});

//xover.listener.on("input", function (event) {
//    if (event.inputType == "insertReplacementText" || event.inputType == null) {
//        document.getElementById("output").textContent = event.target.value;
//        event.target.value = "";
//    }
//});