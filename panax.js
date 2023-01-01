xover.qrl = xover.QRL;
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
                xover.sections.active.render();
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
            history.go(-xo.site.position + 1);
            for (section in xo.sections) {
                xo.sections[section].remove()
            }
            xover.session.status = 'unauthorized';
        } catch (e) {
            Promise.reject(e);
        }
    }, writable: true, configurable: true
})

xo.listener.on(['beforeRender::#shell', 'beforeAppendToHTMLElement::MAIN', 'beforeAppendToHTMLElement::BODY'], function({ target }) {
    if (!(event.detail.args || []).filter(el => !(el instanceof HTMLStyleElement || el instanceof HTMLScriptElement || el.matches("dialog,[role=alertdialog],[role=alert],[role=dialog]"))).length) return;
    [...target.childNodes].filter(el => el.matches && !el.matches(`script,dialog,[role=alertdialog],[role=alert],[role=dialog]`)).removeAll()
})

xo.listener.on([`remove::html:div[@role='alertdialog'][contains(*/@class,'modal')]`], function () {
    let removed_from = this;
    let section = removed_from.getAttribute("xo-section");
    if (section && section in xover.sections) {
        delete xover.sections[section];
    }
})

xo.listener.on(['render::*'], function () {
    this.selectNodes("//button[not(@type)]").forEach(el => el.set("type", "button")) //default behavior
})

xo.listener.on(`change::xo:r/@*[not(contains(namespace-uri(),'http://panax.io/state'))]`, function ({ element, attribute, old, value }) {
    let initial_value = element.getAttributeNodeNS('http://panax.io/state/initial', attribute.nodeName.replace(':', '-'));
    if (value !== null && !initial_value) {
        element.set(`initial:${attribute.nodeName.replace(':', '-')}`, old);
    }
    element.set(`prev:${attribute.nodeName.replace(':', '-')}`, old);
})

xo.listener.on(`beforeChange::xo:r/@meta:*`, function ({ node, element, attribute, old, value }) {
    let references = element.$$(`ancestor::px:Entity[1]/px:Record/px:Association[@AssociationName="${node.localName}"]/px:Mappings/px:Mapping/@Referencer`);
    let src_element = event.srcEvent.srcElement;
    let selected_record = src_element[src_element.selectedIndex].scope.filter("self::xo:r")

    references.forEach(reference => element.set(reference.value, selected_record && selected_record.get(reference.parentNode.get("Referencee")) || ""));
    let option = src_element[src_element.selectedIndex]
    this.value = option.value && option.text || "";
})

const CONVERT = function (type, ...args) { return args }
xo.listener.on(`change::px:Entity//data:rows/xo:r/@*[not(contains(namespace-uri(),'http://panax.io/'))]`, function ({ element: row, attribute, old, value }) {
    if (old != value) {
        row.$$(`ancestor::px:Entity[1]/px:Record/px:Field/@formula`).map(attr => [attr.parentNode.get("Name"), attr.value.replace(/\[([^\]]+)\]/g, (field) => row.get(field.substring(1, field.length - 1)) || 0)]).forEach(([key, formula]) => row.set(key, eval(formula)))
    }
})

xo.listener.on('remove::px:Entity//data:rows', function () {
    let command = this.get("command")
    let previous_parent = this.previousParentNode;
    if (!this.previousParentNode.$(`data:rows[@command="${command}"]`) && previous_parent.getAttribute(`@data:rows`) == command) {
        let data_rows = xover.xml.createNode(`<data:rows xmlns:data="http://panax.io/source"/>`);
        data_rows.reseed();
        this.previousParentNode.append(data_rows);
        data_rows.set("command", command);
    }
})

xo.listener.on('render::px:Entity', function () {
    this.select(`//*[@data:rows and not(data:rows)]`).forEach(node => node.set("@data:rows", node.get("data:rows")))
})

xo.listener.on('set::@data:rows', function ({ value, old: prev }) {
    let current = value != prev && this.parentNode && this.parentNode.$(`data:rows`);
    current && current.remove();
    if (!this.parentNode.$(`data:rows`)) {
        let data_rows = xover.xml.createNode(`<data:rows xmlns:data="http://panax.io/source"/>`).reseed();
        this.parentNode.append(data_rows);
        data_rows.set("command", value);
    }
})

xo.listener.on(['change::px:Entity//data:rows/@command', 'remove::data:rows[not(xo:r)]/@xsi:nil'], async function ({ value, old: prev }) {
    //let current = this.parentNode && this.parentNode.$(`data:rows[@command="${prev}"]`);
    let node = this.parentNode;
    let targetNode = node
    let command = node.get("command");

    let headers = new Headers({
        "Accept": content_type.xml
    })
    let response;
    try {
        response = await xover.sources[`${node.nodeName}:=${command}`].fetch(xover.json.tryParse(command), {
            source: node
            , method: 'GET'
            , headers: headers
        })
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
        new_node.selectNodes('@*').forEach(attr => targetNode.setAttributeNS(attr.namespaceURI, attr.name, attr.value))
        targetNode.append(...new_node.childNodes);
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
    this.parentNode.$$(`*[local-name()="layout"]//association:ref`).map(node => node.$(`ancestor::px:Entity[1]/px:Record/px:Association[@AssociationName="${node.get("Name")}"][not(@Type="belongsTo")]`)).filter(el => el).forEach(association => {
        //let identity_value, primary_values
        //association.$$('px:Mappings/px:Mapping').map(mapping => association.get("DataType") == 'belongsTo' && [mapping.get("Referencer"), node.get(mapping.get("Referencer"))] || mapping.get())
        if (!["belongsTo"].includes(association.getAttribute("Type"))) {
            let target_rows = this.select(`xo:r[not(px:Association[@AssociationName="${association.get("AssociationName")}"])]`)
            if (target_rows.length) {
                let association_copy = association.cloneNode(true);
                association_copy.select(".//@xo:id").remove();
                association_copy.reseed();
                target_rows.map(row => row.append(association_copy)).forEach(els => {
                    els.forEach(el => {
                        let entity = el.$(`px:Entity`);
                        px.loadData(entity);
                    });
                });
            }
        } else {
            let entity = association.$(`px:Entity`);
            px.loadData(entity);
        }
    });
    let section = this.ownerDocument.section;
    if (section && !this.selectFirst("px:Association")) {
        section.render()
    }
    //if (this.parentNode instanceof Document) {
    //    console.log(this)
    //}
})

xo.listener.on(['beforeChange::@headerText', 'beforeChange::@container:*'], function ({ element, attribute, value, old }) {
    if (!element.has(`initial:${attribute.prefix && attribute.prefix + '-' || ''}${attribute.localName}`)) {
        element.set(`initial:${attribute.prefix && attribute.prefix + '-' || ''}${attribute.localName}`, old)
    }
    element.set(`prev:${attribute.prefix && attribute.prefix + '-' || ''}${attribute.localName}`, old)
    this.value = value.replace(/:/g, '').trim()
})

xo.listener.on(['beforeRemove::xo:r'], function ({ element, attribute, value, old }) {
    if (px.getPrimaryValue(this).substr(1) && !element.get("state:delete")) {
        element.toggle('state:delete', true)
        event.preventDefault()
    }
})

function isnull(value, failover) {
    return value != null && value || failover;
}

app = {}

app.request = async function (object_name, mode) {
    let parts = object_name.split('/') || [];
    let name = parts.pop();
    let schema = parts.pop();
    return xo.sources.defaults["#" + name] || xo.xml.createDocument(`<?xml-stylesheet type="text/xsl" href="form.xslt" target="@#shell main"?><?xml-stylesheet type="text/xsl" href="shell_buttons.xslt" target="@#shell #shell_buttons" action="replace"?><${name} schema="${schema}"/>`)
}

px = {}

px.getPrimaryValue = function (record) {
    let entity = record.$(`ancestor::px:Entity[1]`)
    id = entity.$$(`px:Record/px:Field[@IsIdentity="1"]/@Name`).map(key => record.get(key.value));
    pks = entity.$$(`px:PrimaryKeys/px:PrimaryKey/@Field_Name`).map(key => record.get(key.value));
    if (id.length) {
        return ":" + id.join("/")
    } else if (pks.length) {
        return "/" + pks.join("/")
    } else {
        return ""
    }
}

px.editSelectedOption = function (src_element) {
    let selected_record = src_element instanceof HTMLSelectElement && src_element[src_element.selectedIndex].scope.filter("self::xo:r").filter(el => el instanceof Element);
    if (!selected_record) {
        return Promise.reject("No hay registro asociado")
    }
    let primary_value = px.getPrimaryValue(selected_record);
    let href
    if (primary_value.substr(1)) {
        let entity = selected_record.$(`ancestor::px:Entity[1]`)
        href = `#${entity.get("Schema")}/${entity.get("Name")}${primary_value}~edit`
    } else {
        return Promise.reject("No se puede editar el registro")
    }
    xo.site.seed = href
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
    var on_success = function (xml_document) { xover.sections.active = xml_document; };
    let rebuild;
    let reference = xo.site.reference || {};
    let ref_section = xo.sections[reference.section];
    let ref_node = ref_section && ref_section.findById(reference.id) || null;
    if (reference.id && !ref_node && reference.id == xo.qrl(location.hash.substr(1))["ref_node"]) {
        return Promise.reject("Se perdió la referencia.")
    }
    association_ref = ref_node && ref_node.$("ancestor::px:Entity[1]/parent::px:Association")
    if (typeof (request_or_entity_name) == 'string') {
        ({
            fields, schema, name: entity_name, mode, identity_value, primary_values, ref_node, predicate: filters, settings: url_settings
        } = xo.QRL(request_or_entity_name));
        page_size = url_settings["pageSize"];
        page_index = url_settings["pageIndex"];

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
    let mock_section = xo.Section(xo.xml.createDocument(`<entity ${xover.json.toAttributes({ filters, mode, page_size, page_index, Name: entity_name, Schema: schema })}/>`), { tag: `#${schema}/${entity_name}~${mode}`.toLowerCase() });
    let other_filters = Object.fromEntries(xo.manifest.getSettings(mock_section, 'filters'));
    mock_section.remove();
    filters = Object.assign(filters, other_filters);
    ////if (other_filters && other_filters[0] === '`') {
    ////    let entity = { schema: schema, name: entity_name };
    ////    other_filters = eval(other_filters.replace(/\\/g, '\\\\')).replace(/\\b/g, '\\b');
    ////}
    //filters = [...Object.entries(filters), ...Object.entries(other_filters)].map(([key, value]) => `[${key}]='${value.replace(/'/g,"''")}'`).join(' AND ')+'&';
    ////filters = [filters, other_filters].filter(f => f).join(' AND ').replace(/'/g, "''");

    ////var current_location = window.location.hash.match(/#(\w+):(\w+)/);
    rebuild = ((xover.listener.keypress.altKey || xover.session.autoRebuild) ? '1' : [rebuild, 'DEFAULT'].coalesce());
    let current_section = xover.sections.active;
    current_section.state.busy = true;
    try {
        let Response = await xover.server.request(`command=[#entity].request @@user_id=NULL, @full_entity_name='[${schema}].[${entity_name}]', @mode=${(!mode ? 'DEFAULT' : `'${mode}'`)}, @page_index=${(page_index || 'DEFAULT')}, @page_size=${(page_size || 'DEFAULT')}, @max_records=DEFAULT, @control_type=DEFAULT, @Filters=DEFAULTS, @lang=es, @rebuild=${rebuild}, @column_list=DEFAULT, @output=HTML`, {
            headers: {
                "Content-Type": 'text/xml'
                , "Accept": 'text/xml'
                , "x-Detect-Input-Variables": false
                , "x-Detect-Output-Variables": false
                , "x-Debugging": xover.debug.enabled
            }
        })
        //Request.requester = ref;
        if (!(Response instanceof xover.Section) && Response && Response.documentElement) {
            Response = Response.transform("xover/databind.xslt")
            Response.$$('//px:Entity').set("meta:type", "entity")
            let control_type = (Response.$('//px:Entity').getAttribute("xsi:type") || '').replace(':control', '.xslt')
            Response.addStylesheet({ href: "px-Entity.xslt", target: "@#shell main" });
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
            //current_section.state.busy = undefined;
            //let section = new xover.Section(xml_document)
            //var caller = xover.sections.find(Request.requester)[0];
            //if (caller && caller.selectSingleNode('self::px:dataRow')) {
            //    var new_datarow = section.document.selectSingleNode('*/px:data/px:dataRow')
            //    if (new_datarow) {
            //        new_datarow.setAttribute('x:id', caller.getAttribute('x:id'))
            //    }
            //}
            //if (caller && caller.selectSingleNode('(ancestor-or-self::*[@Name and @Schema][1])[@foreignReference]')) {
            //    section.document.documentElement.setAttribute('x:reference', caller.getAttribute('x:id'), false)
            //    var foreignReference = caller.selectSingleNode('ancestor-or-self::*[@foreignReference]');
            //    if (foreignReference) {
            //        section.documentElement.selectNodes('//px:layout//px:field[@fieldName="' + foreignReference.getAttribute('foreignReference') + '"]').remove(false);
            //    }
            //}
            //section.addStylesheet({ href: 'xover/panax/panax_bindings.xslt', target: 'self', action: 'replace' });
            //section.initialize();
            //xover.sections.active = section;
        }
    } catch (e) {
        current_section.state.busy = undefined;
        if (e.document instanceof HTMLDocument) {
            return Promise.reject(xover.dom.createDialog(e.document));
        } else {
            return Promise.reject(e);
        }
    }
}

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
    if (entity.matches("/px:Entity")) {
        let reference = xo.site.reference || {};
        let ref_section = xo.sections[reference.section];
        let ref_node = ref_section && ref_section.findById(reference.id) || null;
        if (ref_node && reference.id == xo.qrl(location.hash.substr(1))["ref_node"] && ref_node.matches("xo:r")) {
            let data_rows = entity.$("data:rows") || entity.createNode(`<data:rows xmlns:data="${ref_node.resolveNS("data")}"/>`)
            data_rows.append(ref_node.cloneNode(true))
            return;
        }
    }
    if (entity.$('data:rows')) return;
    keys = Object.assign({ identity_value: undefined, primary_values: [] }, keys);
    let id = entity.$$(`px:Record/px:Field[@IsIdentity="1"]/@Name`).map(key => [key, keys.identity_value]);
    let pks = entity.$$(`px:PrimaryKeys/px:PrimaryKey/@Field_Name`).map((key, ix) => [key, keys.primary_values[ix]]);
    let filters = Object.entries(keys["filters"] || {});
    let page_size = keys["page_size"];
    let page_index = keys["page_index"];
    constraints = [...id, ...pks]

    let fields = Object.fromEntries(constraints.map(([key]) => key).concat(entity.$$('@custom:*|px:Record/px:Field/@Name|px:Record/px:Association[@Type="belongsTo"]/px:Mappings/px:Mapping/@Referencer|px:Record/px:Association[@Type="belongsTo"]/@Name')).map(field => field.prefix == 'custom' ? [`${field.nodeName}`, field.value] : [`${field.parentNode.nodeName == 'px:Association' && 'meta:' || ''}${field.value}`, `#panax.${field.parentNode.$("self::*[@DataType='nvarchar' or @DataType='foreignKey']") ? 'prepareString' : (field.parentNode.$("self::*[@DataType='xml']") ? 'prepareXML' : 'prepareValue')}(` + (field.parentNode.$("self::px:Association") && `(SELECT ${field.parentNode.$("px:Entity/@displayText|px:Entity[not(@displayText)]/@combobox:text").value} FROM [${field.parentNode.$("px:Entity/@Schema").value}].[${field.parentNode.$("px:Entity/@Name").value}] #parent WHERE ${field.parentNode.$$('px:Mappings/px:Mapping').map(map => '[' + entity.get("Name") + '].[' + map.get("Referencer") + '] = #parent.[' + map.get("Referencee") + ']').join(' AND ')})` || `[${field.value}]`) + ')']))

    let text = entity.$$(`@displayText|self::*[not(@displayText)]/@combobox:text|px:Record/px:Field[not(@IsIdentity="1" or @DataType="xml")][1]/@Name|px:Record[not(*[2])]/px:Field/@Name`).shift();
    fields["meta:text"] = `RTRIM(#panax.${text.parentNode.getAttribute("DataType") == 'xml' && 'prepareXML' || 'prepareString'}(${text.value}))`; // No se ponen brackets para los nombres de las funciones
    //if (id.length) {
    fields["meta:id"] = id.map(el => `#panax.prepareValue([${el[0]}])`).join("+'/'+");
    //} else {
    //let mappings = entity.$$("ancestor::px:Association[1][@Type='belongsTo']/px:Mappings/px:Mapping/@Referencee")
    fields["meta:value"] = pks.map(el => `RTRIM(#panax.prepareString([${el[0]}]))`).join("+'/'+");
    //}
    fields["meta:orderBy"] = entity.get("custom:sortBy")

    let formatValue = (value => (isNumber(value) || value === null) && String(value) || value !== undefined && value[0] != "'" && `'${value}'` || value || '');
    constraints = constraints.concat([...filters]);

    let predicate = constraints.filter(([, value]) => value !== undefined).map(([key, value]) => (key instanceof Attr || value) && `[${key}] IN (${(value instanceof Array) ? value.map(item => formatValue(item)) : formatValue(value)})` || key).join(' AND ')
    Object.entries(predicate).map(([key, value]) => value && `[${key}]='${value.replace(/'/g, "''")}'` || key).join(' AND ')

    let parent_row = entity.$('ancestor::xo:r');
    if (parent_row) {
        let parent_relationship = entity.$('parent::px:Association[not(@Type="belongsTo")]/px:Mappings')
        let mappings = parent_relationship && parent_relationship.$$('px:Mapping').map(map => `[${entity.get("Name")}].[${map.get("Referencer")}] IN ('${parent_row.get(map.get("Referencee")) || 'NULL'}')`) || [];
        predicate && mappings.unshift(predicate);
        predicate = mappings.join(' AND ')
    }
    entity.setAttribute("data:rows", `${entity.get("Schema")}/${entity.get("Name")}?${predicate || ''}#?&pageIndex=${page_index || 1}&pageSize=${page_size || (parent_row ? '100' : '1000')}#${Object.entries(fields).filter(([, value]) => value).sort((first, second) => first[1].indexOf("XML") - second[1].indexOf("XML")).map(([key, value]) => `[${value.indexOf("prepareXML") == -1 ? '@' + key : "x:f/@Name]='" + key + "', [x:f"}]=${value.replace(/#panax\.prepareXML/, '')}`).join(',')}`)
    let section = entity.section;
}

px.getData = async function (...args) {
    let settings = args.pop() || {};
    let parameters = args.pop() || {};
    let node = settings["source"];
    if (node) {
        let command = parameters;
        let attribute_base_name = node.localName;
        let fields, request, predicate = {}, url_settings;
        if (parameters && typeof (parameters.value || parameters) === 'string') {
            ({
                fields, schema, name, mode, identity_value, primary_values, predicate, settings: url_settings
            } = xo.QRL(parameters));
            page_size = url_settings["pageSize"];
            page_index = url_settings["pageIndex"];
            request = `[${schema}].[${name}]`
            ////let [request_with_fields, ...predicate] = command.split(/=>|&filters=/);
            ////let [fields, request] = comnd.match('(?:(.*)~>)?(.+)');
            //[rest, page] = parameters.indexOf("#:=") != -1 && parameters.split("#:=") || [parameters, "1/20"];
            //[rest, predicate = ''] = rest.split("=>");
            //[fields, request] = rest.indexOf("~>") != -1 && rest.split("~>") || ["*", rest];
            ////let [, fields, request, predicate = ''] = command.match('(?:(.*)~>|^)?((?:(?<!=>).)+)(?:=>(.+))?$');

            /*TODO: Mover esto a un listener o definir */
            //parameters = (node.getAttribute('source_filters:' + attribute_base_name) || predicate || "");
            predicate = Object.fromEntries(Object.entries(predicate));
            parameters = Object.entries(predicate).filter(([key, value]) => key[0] != '@').map(([key, value]) => value && `[${key}]='${value.replace(/'/g, "''")}'` || key).join(' AND ')
        }
        let root_node = node.prefix.replace(/^request$/, "source") + ":" + attribute_base_name;
        //

        let headers = new Headers(xover.json.merge(settings["headers"] instanceof Headers && Object.fromEntries(settings["headers"].entries()), {
            "Cache-Response": (node.parentNode && Array.prototype.coalesce(eval(node.getAttribute("cache" + ":" + (attribute_base_name))), eval(node.parentNode && node.parentNode instanceof Element && node.parentNode.getAttribute("cache" + ":" + (attribute_base_name))), false))
            , "Accept": content_type.xml
            , "cache-control": 'force-cache'
            , "pragram": 'force-cache'
            , "x-original-request": command
            , "x-namespaces": `'${node.resolveNS(node.prefix)}' as ${node.prefix}`
            , "x-Root-Node": root_node
            , "x-Page-Index": (page_index || '')
            , "x-Page-Size": (page_size || '')
            , "x-Detect-Missing-Variables": "false"
            , "x-Debugging": xover.debug.enabled
            , "x-data-text": encodeURIComponent(node.getAttribute('source_text:' + attribute_base_name) || node.getAttribute('dataText') || "")
            , "x-data-value": encodeURIComponent(node.getAttribute('source_value:' + attribute_base_name) || node.getAttribute('dataValue') || "")
            , "x-data-fields": fields || ""
            , "x-order-by": node.parentNode instanceof Element && node.parentNode.get("custom:sortBy") || ""
        }))
        settings["headers"] = headers;
        parameters = request && { command: request, predicate: parameters } || {};
        Object.assign(parameters, Object.fromEntries(Object.entries(predicate).filter(([key, value]) => key[0] == '@')));
    }
    args.push(parameters);
    args.push(settings);
    try {
        let response = await xo.server.request.apply(this, args);
        if (!(node && node.parentElement)) return;
        let entity = node.parentElement.$('self::px:Entity[ancestor-or-self::*[@mode="add"] and not(parent::px:Association[@Type="hasMany"])]')
        //let entity = node.$('parent::px:Entity[//px:Entity[@mode="add"]]')
        if (entity && !(response.documentElement.firstElementChild)) {
            response.documentElement.append(px.createEmptyRow(entity))
        }
        return response
    } catch (e) {
        return Promise.reject(e)
    }
}

px.applyFilters = function (attribute_node) {
    let command = xo.QRL(attribute_node);
    attribute_node.select("ancestor::px:Entity/px:Parameters//px:Parameter").forEach(param => {
        command.predicate[param.getAttribute("parameterName")] = (param.getAttribute("value") || "null")
    })
    attribute_node.set(command.toString());
}

px.createEmptyRow = function (entity) {
    let fields = [...new Set(entity.$$('px:Record/px:Field/@Name|px:Record/px:Association[@Type="belongsTo"]/px:Mappings/px:Mapping/@Referencer|px:Record/px:Association[@Type="belongsTo"]/@Name').map(field => ((field.parentNode.nodeName == 'px:Association' ? 'meta:' : '') + field.value) + '=""'))].join(' ')
    return xo.xml.createNode(`<xo:r xmlns:xo="http://panax.io/xover" ${fields}/>`).reseed();
}

px.navigateTo = function (hashtag, ref_id) {
    ref_id = ref_id || (event.srcElement.scope.$("data:rows/@xo:id") || {}).value;
    hashtag = (hashtag || "").replace(/^([^#])/, '#$1');
    let section = xo.sections[hashtag];
    section && section.remove();
    if ([xo.site.seed, ...(xo.site.activeTags() || [])].includes(hashtag) || xover.sections[hashtag].isRendered) { //TODO: Revisar si isRendered siempre 
        xo.site.active = hashtag;
    } else {
        xo.site.next = hashtag;

        let public_hashtag = hashtag//Array.prototype.coalesce(public_hashtag || hashtag)
        var prev = (history.state["prev"] || [])
        prev.unshift({ section: xo.site.seed, ref: ref_id })
        history.pushState({
            seed: hashtag
            , reference: {
                section: xo.site.seed
                , id: ref_id
            }
            //, active: hashtag
            , prev: prev
        }, ((event || {}).target || {}).textContent, public_hashtag);
        xo.site.active = hashtag;
    }
    xover.sections.active.render();
}

function saveConfiguration() {
    xo.sections.active.documentElement.$$('//px:Record/*/@prev:*').map(attr => [`[${attr.parentNode.$('ancestor::px:Entity[1]').get('Schema')}].[${attr.parentNode.$('ancestor::px:Entity[1]').get('Name')}]`, (attr.parentNode.get("AssociationName") || attr.parentNode.get("Name")), `@${attr.localName.replace('-', ':')}`, attr.parentNode.get(attr.localName.replace('-', ':'))]).map(el => el.map(item => `'${item}'`)).forEach(config => xo.server.request({ command: "[#entity].[config]", parameters: config }, {}).then(response => response.render && response.render()))
}

xo.spaces["post"] = "http://panax.io/persistence";
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
                return initial && initial.value && initial.value != row.get(`${field}`) || false
            }).length) {
                dataRow = xo.xml.createNode(`<updateRow xmlns="http://panax.io/persistence"${id ? ` identityValue="${row.get(id.value)}"` : ''}/>`);
                entity.$$('px:Record/px:Field[not(@IsIdentity="1" or @formula)]/@Name').filter(field => !mappings.find(mapping => mapping.value == field.value)).forEach(field => {
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
                entity.$$('px:Record/px:Field[not(@IsIdentity="1" or @formula)]/@Name').filter(field => !mappings.find(mapping => mapping.value == field.value)).forEach(field => {
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
            return buildPost(foreign_entity.$$('data:rows/xo:r'), dataRow)
        })
    }
    return target;
}

px.submit = function (data_rows) {
    data_rows = data_rows instanceof Array ? data_rows : [data_rows];
    let reference = xo.site.reference || {};
    let ref_section = xo.sections[reference.section];
    let ref_node = ref_section && ref_section.findById(reference.id) || null;
    if (ref_node && reference.id == xo.qrl(location.hash.substr(1))["ref_node"]) {
        if (ref_node.matches("xo:r")) {
            ref_node.replaceWith(data_rows[0])
        } else if (ref_node.matches("data:rows")) {
            ref_node.selectFirst("ancestor::px:Entity[1]/px:Record").replaceWith(data_rows[0].selectFirst("ancestor::px:Entity[1]/px:Record").cloneNode(true));
            ref_node.append(...data_rows)
        }
        let srcElement = event.srcElement;
        let interface = srcElement && srcElement.closest("[role='alertdialog']") || xo.sections.active;
        interface.remove();
        return;
    }
    //if (ref_node && ref_node.$('ancestor::px:Association')) {
    //    ref_node.selectFirst("ancestor::px:Entity[1]/px:Record").replaceWith(data_rows[0].selectFirst("ancestor::px:Entity[1]/px:Record").cloneNode(true));
    //    ref_node.append(...data_rows);
    //    xo.sections.active.remove();
    //    return
    //}
    for (let row of data_rows) {
        let post = buildPost([row])
        let messages = post.select("//@exception:message").map(el => document.createElement('li').set(new Text(el.value)));
        if (messages.length) {
            let list = document.createElement("ul");
            list.append(...messages);
            xo.dom.alert(list)
            return;
        }
        try {
            xover.listener.dispatchEvent(new xover.listener.Event('beforeSubmit', { post: post }), row);
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
                result_document.$$('//result[@status="error"]/@statusMessage').forEach(el => el.render())
                result_document.render()
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

xo.listener.on('load::px:Entity', function () {
    let entity = this;
    let prev = (xo.site.prev || [])[0] || {};
    let ref_section = xo.sections[prev.section];
    let ref_node = ref_section && ref_section.findById(prev.ref) || null;
    ref_node && ref_node.$$('ancestor::px:Association[1]').map(el => entity.$(`px:Entity/*[local-name()="layout"]/association:ref[@Name="${el.get("AssociationName")}"]`)).forEach(el => el && el.remove())

    entity.$$('px:Entity/px:Record/px:Field[@mode="hidden"]').map(el => entity.$(`px:Entity/*[local-name()="layout"]/field:ref[@Name="${el.get("Name")}"]`)).forEach(el => el && el.remove())
})

xo.listener.on(['response::xo:prompt'], function ({ response_value }) {
    let response = this;
    new xo.Section(response.document, { tag: "#prompt" });
})

xo.listener.on('response::server:submit', function ({ request, payload }) {
    let reference = xo.site.reference || {};
    let ref_section = xo.sections[reference.section];
    let ref_node = ref_section && ref_section.findById(reference.id) || null;
    if (reference.id && !ref_node && reference.id == xo.qrl(location.hash.substr(1))["ref_node"]) {
        return Promise.reject("Se perdió la referencia.")
    }
    let result = this.document;
    let scope = ((request.settings || {})["body"] || {})["scope"];
    if (!(result instanceof Node)) return;
    if (result.$$('//result').length && result.$$('//result').every(r => r.get("status") == 'success')) {
        let entity = scope.$("ancestor-or-self::px:Entity[last()]");
        if (!entity) return;
        if ((entity.getAttribute("control:type") || '').indexOf('form') != -1) {
            ref_node && ref_node.select("(ancestor::px:Entity[1][@data:rows]/data:rows|ancestor-or-self::data:rows[1])[last()]").remove();
            //ref_section && ref_section.$$(`//px:Entity[@Schema="${entity.get("Schema")}" and @Name="${entity.get("Name")}"][@data:rows]/data:rows`).removeAll()
            entity.ownerDocument.section.remove();
            xo.site.set("dirty", Object.fromEntries([["Schema", entity.getAttribute("Schema")], ["Name", entity.getAttribute("Name")]]))
        } else {
            entity.$$('//data:rows').remove()
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

xover.listener.on('hashchange', function (new_hash, old_hash) {
    let dirty_entity = xover.site.get("dirty");
    //xo.sections.active.select(`//px:Entity/data:rows/@xsi:nil|//px:Entity/data:rows[not(*)]|//px:Entity[@Schema="${dirty_entity["Schema"]}" and @Name="${dirty_entity["Name"]}"]/data:rows`).remove();
    xo.sections.active.select(`//px:Entity/data:rows/@xsi:nil`).remove();
    xo.sections.active.select('//px:Entity[@data:rows][not(data:rows)]').set("data:rows", ({ el }) => el.get("data:rows"));
    xover.site.set("dirty", undefined)
});