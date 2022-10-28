Object.defineProperty(xo.session, 'login', {
    value: async function (username, password, connection_id = window.location.hostname) {
        try {
            let _username = username.value || username
            let _password = password.value || password
            xover.session.user_login = _username
            xover.session.status = 'authorizing';
            let response = await xover.server.login(new URLSearchParams({ 'connection_id': connection_id }), { headers: { authorization: `Basic ${btoa(_username + ':' + _password)}` } });
            xover.session.status = 'authorized';
            xover.sections.active.render();
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
            for (section in xo.sections) {
                xo.sections[section].remove()
            }
            xover.session.status = 'unauthorized';
            history.go(-xo.site.position + 1);
        } catch (e) {
            Promise.reject(e);
        }
    }, writable: true, configurable: true
})

xo.listener.on(['beforeRender::#shell', 'beforeAppendToHTMLElement::MAIN', 'beforeAppendToHTMLElement::BODY'], ({ target }) => {
    if (!(event.detail.args || []).filter(el => !(el instanceof HTMLStyleElement || el instanceof HTMLScriptElement || el.matches("dialog,[role=alertdialog],[role=alert],[role=dialog]"))).length) return;
    [...target.childNodes].filter(el => el.matches && !el.matches(`script,dialog,[role=alertdialog],[role=alert],[role=dialog]`)).removeAll()
})

xo.listener.on(`change::xo:r/@*[not(contains(namespace-uri(),'http://panax.io/state'))]`, function ({ element, attribute, old, value }) {
    let initial_value = element.getAttributeNodeNS('http://panax.io/state/initial', attribute.localName);
    if (value !== null && !initial_value) {
        element.set(`initial:${attribute.localName}`, old);
    } else if (initial_value.value === value) {
        initial_value.remove();
    }
    element.set(`prev:${attribute.localName}`, old);
})

xo.listener.on(`beforeChange::xo:r/@meta:*`, function ({ node, element, attribute, old, value }) {
    let references = element.$$(`ancestor::px:Entity[1]/px:Record/px:Association[@AssociationName="${node.localName}"]/px:Mappings/px:Mapping/@Referencer`);
    let src_element = event.srcEvent.srcElement;
    let selected_record = src_element[src_element.selectedIndex].scope.filter("self::xo:r")

    references.forEach(reference => element.set(reference.value, selected_record && selected_record.get(reference.parentNode.get("Referencee")) || ""));
    let option = src_element[src_element.selectedIndex]
    event.detail.value = option.value && option.text || "";
})

xo.listener.on(`change::px:Entity/data:rows/xo:r/@*[not(contains(namespace-uri(),'http://panax.io/'))]`, function ({ element: row, attribute, old, value }) {
    if (old != value) {
        row.$$(`ancestor::px:Entity[1]/px:Record/px:Field/@formula`).map(attr => [attr.parentNode.get("Name"), attr.value.replace(/\[([^\]]+)\]/g, (field) => row.get(field.substring(1, field.length - 1)) || 0)]).forEach(([key, formula]) => row.set(key, eval(formula)))
    }
})

xo.listener.on('appendTo::data:rows', function ({ node }) {
    //let empty_node = node.$('xo:empty')
    //if (empty_node) {
    //    let entity = node.parentElement.$('self::px:Entity[@mode="add"][not(parent::px:Association)]')
    //    if (entity) {
    //        let fields = [...new Set(entity.$$('px:Record/px:Field|px:Record/px:Association[@Type="belongsTo"]/px:Mappings/px:Mapping|px:Record/px:Association[@Type="belongsTo"]').map(field => field.$("@Name|@Referencer").value + '=""'))].join(' ')
    //        empty_node.replace(xo.xml.createNode(`<xo:r xmlns:xo="http://panax.io/xover" ${fields}/>`))
    //    }
    //}
    node.parentNode.filter("ancestor-or-self::*[@mode='add' or @mode='edit']").$$(`px:Record/px:Association`).forEach(association => {
        //let identity, primary
        //association.$$('px:Mappings/px:Mapping').map(mapping => association.get("DataType") == 'belongsTo' && [mapping.get("Referencer"), node.get(mapping.get("Referencer"))] || mapping.get())
        entity = association.$(`px:Entity`);
        px.loadData(entity);
    })
})

xo.listener.on('beforeChange::@headerText', function ({ element, attribute, value, old }) {
    if (!element.has(`initial:${attribute.localName}`)) {
        element.set(`initial:${attribute.localName}`, old)
    }
    element.set(`prev:${attribute.localName}`, old)
    event.detail.value = event.detail.value.replace(/:/g, '').trim()
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

px.editSelectedOption = function (src_element) {
    let selected_record = src_element instanceof HTMLSelectElement && src_element[src_element.selectedIndex].scope.filter("self::xo:r").filter(el => el instanceof Element);
    if (!selected_record) {
        return Promise.reject("No hay registro asociado")
    }
    let entity = selected_record.$(`ancestor::px:Entity[1]`)
    id = entity.$$(`px:Record/px:Field[@IsIdentity="1"]/@Name`).map(key => selected_record.get(key.value));
    pks = entity.$$(`px:PrimaryKeys/px:PrimaryKey/@Field_Name`).map(key => selected_record.get(key.value));
    let href
    if (id.length) {
        href = `#${entity.get("Schema")}/${entity.get("Name")}~edit:${id.join("/")}`
    } else if (pks.length) {
        href = `#${entity.get("Schema")}/${entity.get("Name")}~edit/${pks.join("/")}`
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

px.request = async function (request_or_entity_name, mode, filters, ref) {
    if (!request_or_entity_name) {
        return null;
    }
    if (!(xover.manifest.server["request"])) {
        throw ("Endpoint for request is not defined in the manifest");
    }
    var schema, entity_name;
    var page_index, page_size;
    var on_success = function (xml_document) { xover.sections.active = xml_document; };
    let rebuild;
    let reference = xo.site.reference || {};
    let ref_section = xo.sections[reference.section];
    let ref_node = ref_section && ref_section.findById(reference.id) || null;
    if (reference.id && !ref_node) {
        return Promise.reject("Se perdió la referencia.")
    }
    association_ref = ref_node && ref_node.$("ancestor::px:Entity[1]/parent::px:Association")
    if (typeof (request_or_entity_name) == 'string') {
        let parts = request_or_entity_name.split('/') || [];
        entity_name = parts.pop();
        schema = parts.pop();
        mode = (mode || "view");
    }
    if (request_or_entity_name.constructor === {}.constructor) {
        ({ schema, name: entity_name } = request_or_entity_name);
        //schema = request_or_entity_name["schema"]
        //entity_name = (schema ? "[" + schema + "]." : "") + request_or_entity_name["name"];
        if (!schema) {
            let full_name = entity_name;
            [, schema, entity_name] = String(full_name).match(/^\s*\[([^\]]+)\]\.\[(.+)\]\s*$/i);
        }
        mode = (mode || request_or_entity_name["mode"] || "view");
        page_index = request_or_entity_name["pageIndex"];
        page_size = request_or_entity_name["pageSize"];
        filters = (request_or_entity_name["filters"] || filters);
        on_success = (request_or_entity_name["on_success"] || on_success);
        rebuild = request_or_entity_name["rebuild"]
    }
    let identity, primary;
    [mode, identity] = mode.split(':');
    [mode, ...primary] = mode.split('/');
    //primary = primary.filter((item, ix) => ix % 2 != 0) 
    page_size = (page_size || xover.manifest.getSettings(`#${schema}/${mode}:${entity_name}`, "pageSize").pop());
    page_index = (page_index || xover.manifest.getSettings(`#${schema}/${mode}:${entity_name}`, "pageIndex").pop());
    let mock_section = xo.Section(xo.xml.createDocument(`<entity ${xover.json.toAttributes({ filters, mode, page_size, page_index, Name: entity_name, Schema: schema })}/>`), { tag: `${schema}/${mode}:${entity_name}`.toLowerCase() });
    let other_filters = xo.manifest.getSettings(mock_section, 'filters').pop();
    if (other_filters && other_filters[0] === '`') {
        let entity = { schema: schema, name: entity_name };
        other_filters = eval(other_filters.replace(/\\/g, '\\\\')).replace(/\\b/g, '\\b');
    }
    filters = [filters, other_filters].filter(f => f).join(' AND ').replace(/'/g, "''");

    //var current_location = window.location.hash.match(/#(\w+):(\w+)/);
    rebuild = ((xover.listener.keypress.altKey || xover.session.autoRebuild) ? '1' : [rebuild, 'DEFAULT'].coalesce());
    let current_section = xover.sections.active;
    current_section.state.busy = true;
    try {
        let Response = await xover.server.request(`command=[#entity].request @@user_id=NULL, @full_entity_name='[${schema}].[${entity_name}]', @mode=${(!mode ? 'DEFAULT' : `'${mode}'`)}, @page_index=${(page_index || 'DEFAULT')}, @page_size=${(page_size || 'DEFAULT')}, @max_records=DEFAULT, @control_type=DEFAULT, @Filters=${(!filters ? 'DEFAULT' : `'${encodeURIComponent(filters)}'`)}, @lang=es, @rebuild=${rebuild}, @column_list=DEFAULT, @output=HTML`, {
            headers: {
                "Content-Type": 'text/xml'
                , "Accept": 'text/xml'
                , "x-Detect-Input-Variables": false
                , "x-Detect-Output-Variables": false
                , "x-Debugging": xover.debug.enabled
            }
        })
        Request.requester = ref;
        if (!(Response instanceof xover.Section) && Response && Response.documentElement) {
            Response.$$('//px:Entity').set("@meta:type", "entity")
            let control_type = Response.$('//px:Entity').get("xsi:type").replace(':control', '.xslt')
            Response.addStylesheet({ href: control_type, target: "@#shell main" });
            Response.documentElement.setAttributeNS(xover.spaces["xmlns"], "xmlns:data", "http://panax.io/source");
            association_ref && Response.documentElement.$$(`*[local-name()="layout"]/association:*[@name="${association_ref.get("AssociationName")}"]`).remove()
            px.loadData(Response.$('px:Entity'), mode == 'add' && { identity: null, primary: [null] } || { identity, primary })
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
    keys = Object.assign({ identity: undefined, primary: [] }, keys)
    pks = []
    id = entity.$$(`px:Record/px:Field[@IsIdentity="1"]/@Name`).map(key => [key, keys.identity])
    pks = entity.$$(`px:PrimaryKeys/px:PrimaryKey/@Field_Name`).map((key, ix) => [key, keys.primary[ix]])
    constraints = [...id, ...pks]

    let fields = Object.fromEntries(constraints.map(([key]) => key).concat(entity.$$('px:Record/px:Field/@Name|px:Record/px:Association[@Type="belongsTo"]/px:Mappings/px:Mapping/@Referencer|px:Record/px:Association[@Type="belongsTo"]/@Name')).map(field => [`${field.parentNode.nodeName == 'px:Association' && 'meta:' || ''}${field.value}`, `#panax.${field.parentNode.$("self::*[@DataType='nvarchar' or @DataType='foreignKey']") ? 'prepareString' : 'prepareValue'}(` + (field.parentNode.$("self::px:Association") && `(SELECT ${field.parentNode.$("px:Entity/@displayText|px:Entity[not(@displayText)]/@combobox:text").value} FROM [${field.parentNode.$("px:Entity/@Schema").value}].[${field.parentNode.$("px:Entity/@Name").value}] #parent WHERE ${field.parentNode.$$('px:Mappings/px:Mapping').map(map => '[' + entity.get("Name") + '].[' + map.get("Referencer") + '] = #parent.[' + map.get("Referencee") + ']').join(' AND ')})` || `[${field.value}]`) + ')']))

    let text = entity.$$(`@displayText|self::*[not(@displayText)]/@combobox:text|px:Record/px:Field[not(@IsIdentity="1")][1]/@Name|px:Record[not(*[2])]/px:Field/@Name`).shift();
    fields["meta:text"] = `RTRIM(#panax.prepareString(${text.value}))`; // No se ponen brackets para los nombres de las funciones
    //if (id.length) {
    fields["meta:id"] = id.map(el => `#panax.prepareValue([${el[0]}])`).join("+'/'+");
    //} else {
    //let mappings = entity.$$("ancestor::px:Association[1][@Type='belongsTo']/px:Mappings/px:Mapping/@Referencee")
    fields["meta:value"] = pks.map(el => `RTRIM(#panax.prepareString([${el[0]}]))`).join("+'/'+");
    //}
    fields["meta:orderBy"] = entity.get("custom:sortBy")

    let formatValue = (value => (isNumber(value) || value === null) && String(value) || value !== undefined && `'${value}'` || '');
    let predicate = constraints.filter(([, value]) => value !== undefined).map(([key, value]) => `[${key}] IN (${(value instanceof Array) ? value.map(item => formatValue(item)) : formatValue(value)})`).join('AND')
    let parent_entity = entity.$('ancestor::px:Entity[1]');
    if (parent_entity && parent_entity.$('data:rows/*')) {
        let parent_relationship = entity.$('parent::px:Association[not(@Type="belongsTo")]/px:Mappings')
        let mappings = parent_relationship && parent_relationship.$$('px:Mapping').map(map => `[${entity.get("Name")}].[${map.get("Referencer")}] IN ('${parent_entity.$$('data:rows/*').map(row => (row.get(map.get("Referencee")) || 'NULL')).join(',')}')`) || [];
        predicate && mappings.unshift(predicate);
        predicate = mappings.join(' AND ')
    }
    entity.setAttribute("data:rows", `${Object.entries(fields).filter(([, value]) => value).map(([key, value]) => `[@${key}]=${value}`).join(',')}~>[${entity.get("Schema")}].[${entity.get("Name")}]=>${predicate || ''}#:=1/${!parent_entity ? '100' : '1000'}`)
}

px.getEntityFields = async function (entity) {

}

px.getData = async function (...args) {
    let settings = args.pop() || {};
    let parameters = args.pop() || {};
    let node = settings["source"];
    if (node) {
        let command = parameters;
        let attribute_base_name = node.localName;
        let fields, request;
        if (typeof (parameters) === 'string') {
            //let [request_with_fields, ...predicate] = command.split(/=>|&filters=/);
            //let [fields, request] = comnd.match('(?:(.*)~>)?(.+)');
            [rest, page] = parameters.indexOf("#:=") != -1 && parameters.split("#:=") || [parameters, "1/20"];
            [rest, predicate = ''] = rest.split("=>");
            [fields, request] = rest.indexOf("~>") != -1 && rest.split("~>") || ["*", rest];
            //let [, fields, request, predicate = ''] = command.match('(?:(.*)~>|^)?((?:(?<!=>).)+)(?:=>(.+))?$');

            /*TODO: Mover esto a un listener o definir */
            parameters = (node.getAttribute('source_filters:' + attribute_base_name) || predicate || "");
        }
        let root_node = node.prefix.replace(/^request$/, "source") + ":" + attribute_base_name;
        let headers = new Headers(xover.json.merge(settings["headers"] instanceof Headers && Object.fromEntries(settings["headers"].entries()), {
            "Cache-Response": (Array.prototype.coalesce(eval(node.getAttribute("cache" + ":" + (attribute_base_name))), eval(node.parentElement.getAttribute("cache" + ":" + (attribute_base_name))), false))
            , "Accept": content_type.xml
            , "cache-control": 'force-cache'
            , "pragram": 'force-cache'
            , "x-source-tag": node.section.tag
            , "x-original-request": command
            , "x-namespaces": `'${node.resolveNS(node.prefix)}' as ${node.prefix}`
            , "x-Root-Node": root_node
            , "x-Page-Index": page.split("/")[0]
            , "x-Page-Size": page.split("/")[1]
            , "x-Detect-Missing-Variables": "false"
            , "x-Debugging": xover.debug.enabled
            , "x-data-text": encodeURIComponent(node.getAttribute('source_text:' + attribute_base_name) || node.getAttribute('dataText') || "")
            , "x-data-value": encodeURIComponent(node.getAttribute('source_value:' + attribute_base_name) || node.getAttribute('dataValue') || "")
            , "x-data-fields": encodeURIComponent(node.getAttribute('source_fields:' + attribute_base_name) || fields || "")
            , "x-order-by": node.parentNode && node.parentNode.get("custom:sortBy")
        }))
        settings["headers"] = headers;
        parameters = request && { command: request, predicate: parameters } || undefined;
    }
    args.push(parameters);
    args.push(settings);
    try {
        let response = await xo.server.request.apply(this, args);
        let entity = node.parentElement.$('self::px:Entity[@mode="add"][not(parent::px:Association)]')
        //let entity = node.$('parent::px:Entity[//px:Entity[@mode="add"]]')
        if (entity && !(response.documentElement.firstElementChild)) {
            let fields = [...new Set(entity.$$('px:Record/px:Field/@Name|px:Record/px:Association[@Type="belongsTo"]/px:Mappings/px:Mapping/@Referencer|px:Record/px:Association[@Type="belongsTo"]/@Name').map(field => ((field.parentNode.nodeName == 'px:Association' ? 'meta:' : '') + field.value) + '=""'))].join(' ')
            response.documentElement.append(xo.xml.createNode(`<xo:r xmlns:xo="http://panax.io/xover" ${fields}/>`))
        }
        return response
    } catch (e) {
        return Promise.reject(e)
    }
}

function saveConfiguration() {
    xo.sections.active.documentElement.$$('//px:Record/*/@prev:*').map(attr => [`[${attr.parentNode.$('ancestor::px:Entity[1]').get('Schema')}].[${attr.parentNode.$('ancestor::px:Entity[1]').get('Name')}]`, (attr.parentNode.get("AssociationName") || attr.parentNode.get("Name")), `@${attr.localName}`, attr.parentNode.get(attr.localName)]).map(el => el.map(item => `'${item}'`)).forEach(config => xo.server.request({ command: "[#entity].[config]", parameters: config }, {}).then(response => response.render && response.render()))
}

function submit(data_rows) {
    let prev = (xo.site.prev || [])[0] || {};
    let ref_section = xo.sections[prev.section];
    let ref_node = ref_section && ref_section.findById(prev.ref) || null;

    //if (ref_node) {
    //    ref_node.append(...data_rows)
    //    history.go(-1)
    //    return
    //}
    for (let row of data_rows) {
        let post = xo.xml.createNode(`<batch xmlns="http://panax.io/persistence" xmlns:state="http://panax.io/state" xmlns:session="http://panax.io/session"/>`)
        let entity = row.$('ancestor::px:Entity[1]');
        let id = entity.$(`px:Record/px:Field[@IsIdentity="1"]`)
        let data;
        if (row.$('self::*[@state:delete]')) {
            post.append(xo.xml.createNode(`<dataTable xmlns="http://panax.io/persistence" name="[${entity.get("Schema")}].[${entity.get("Name")}]"${id ? ` identityKey="${id.get("Name")}"` : ''}><deleteRow${id ? ` identityValue="${row.get(id.get("Name"))}"` : ''}>${entity.$$('px:Record/px:Field').map((field) => {
                let field_name = field.get("Name");
                let isPK = field.$(`ancestor::px:Entity[1]/px:PrimaryKeys/px:PrimaryKey[@Field_Name="${field_name}"]`)
                if (isPK) {
                    return `<field name="${field.get("Name")}"${isPK ? ` currentValue="'${row.get(`initial:${field.get("Name")}`) || row.get(field.get("Name"))}'" isPK="true"` : ''}></field>`
                }
            }
            ).join('')
                }</deleteRow></dataTable>`))
        } else if (entity.get("mode") == 'add') {
            post.append(xo.xml.createNode(`<dataTable xmlns="http://panax.io/persistence" name="[${entity.get("Schema")}].[${entity.get("Name")}]"${id ? ` identityKey="${id.get("Name")}"` : ''}>
    <insertRow>${entity.$$('px:Record/px:Field[not(@IsIdentity="1" or @formula)]').map((field) => {
                let field_name = field.get("Name");
                let isPK = field.$(`ancestor::px:Entity[1]/px:PrimaryKeys/px:PrimaryKey[@Field_Name="${field_name}"]`)
                return `<field name="${field.get("Name")}"${isPK ? ` isPK="true"` : ''}>${[row.get(field.get("Name"))].map(val => !val && (field.get("defaultValue") || 'null') || `'${val}'`)}</field>`
            }).join('')
                }</insertRow></dataTable>`))

        } else {
            post.append(xo.xml.createNode(`<dataTable xmlns="http://panax.io/persistence" name="[${entity.get("Schema")}].[${entity.get("Name")}]"${id ? ` identityKey="${id.get("Name")}"` : ''}><updateRow${id ? ` identityValue="${row.get(id.get("Name"))}"` : ''}>${entity.$$('px:Record/px:Field[not(@IsIdentity="1" or @formula)]').map((field) => {
                let field_name = field.get("Name");
                let new_value = row.get(field_name);
                let isPK = field.$(`ancestor::px:Entity[1]/px:PrimaryKeys/px:PrimaryKey[@Field_Name="${field_name}"]`)

                return `<field name="${field.get("Name")}"${isPK ? ` currentValue="'${row.get(`initial:${field.get("Name")}`) || row.get(field.get("Name"))}'" isPK="true"` : ''}>${[new_value].map(val => !val && 'null' || `'${val}'`)}</field>`
            }
            ).join('')
                }</updateRow></dataTable>`))
        }
        row.setAttribute("xmlns:session", "http://panax.io/session")
        payload = xover.xml.createDocument(`<x:post xmlns:x="http://panax.io/xover" xmlns:session="http://panax.io/session"><x:source>${row.toString()}</x:source><x:submit>${post.toString()}</x:submit></x:post>`);
        xover.server.submit(payload, { responseHandler: (return_value, request, response) => [return_value, request, response] })
            .then(([result, request]) => {
                if (result.$$('//result').every(r => r.get("status") == 'success')) {
                    if (entity.get("control:type").indexOf('form') != -1) {
                        entity.ownerDocument.section.remove();
                    } else {
                        entity.$$('//data:rows').remove()
                    }
                }
            }).catch(response => {
                try {
                    let message = response.documentElement.$$(`//results/result[@status='error']`).map(r => r.get("statusMessage")).join('<br/>')
                    xo.dom.alert(message)
                } catch (e) {
                    xo.dom.alert(e)
                }
            })
    }
    //xo.server.post({
    //    body: body
    //})
}

px.navigateTo = function (hashtag, ref_id) {
    ref_id = ref_id || (event.srcElement.scope.$("data:rows/@xo:id") || {}).value;
    hashtag = (hashtag || "").replace(/^([^#])/, '#$1');
    if ([xo.site.seed, ...(xo.site.activeTags() || [])].includes(hashtag) || xover.sections[hashtag].isRendered) { //TODO: Revisar si isRendered siempre 
        xo.site.active = hashtag;
    } else {
        xo.site.next = hashtag;

        let public_hashtag = hashtag//Array.prototype.coalesce(public_hashtag || hashtag)
        var prev = (history.state["prev"] || [])
        prev.unshift({ section: xo.site.seed, ref: ref_id })
        history.pushState({
            seed: hashtag
            //, active: hashtag
            , prev: prev
        }, ((event || {}).target || {}).textContent, public_hashtag);
    }
    xover.sections.active.render();
}
