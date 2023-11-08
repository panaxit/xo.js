<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xo="http://panax.io/xover"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:control="http://www.w3.org/2001/XMLSchema-instance"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:custom="http://panax.io/custom"
  xmlns:data="http://panax.io/source"
  xmlns:state="http://panax.io/state"
  xmlns:filter="http://panax.io/state/filter"
  xmlns:meta="http://panax.io/metadata"
  xmlns:combobox="http://panax.io/widget/combobox"
  xmlns:comboboxButton="http://panax.io/widget/combobox-button"
  xmlns:route="http://panax.io/routes"
  xmlns:px="http://panax.io/entity"
  exclude-result-prefixes="xo xsl combobox data px"
>
	<xsl:import href="keys.xslt"/>

	<xsl:key name="combobox:widget" match="node-expected" use="@xo:id"/>

	<xsl:template mode="widget-attributes" match="@*" priority="-1"/>

	<xsl:template mode="combobox:attributes" match="@*" priority="-1">
		<xsl:apply-templates mode="widget-attributes" select="."/>
	</xsl:template>

	<xsl:template mode="combobox:preceding-siblings" match="@*" priority="-1"></xsl:template>

	<xsl:template mode="combobox:following-siblings" match="@*" priority="-1"></xsl:template>

	<xsl:template mode="comboboxButton:widget" match="@*">
		<xsl:param name="selection" select="node-expected"/>
		<xsl:param name="items" select="ancestor-or-self::*[1]"/>
		<xsl:variable name="id" select="ancestor-or-self::*[@xo:id][1]/@xo:id"/>
		<span class="input-group-append" style="color:black;" xo-scope="{$id}">
			<button type="button" class="btn btn-secondary btn-lg dropdown-toggle h-100" data-bs-toggle="dropdown" aria-expanded="false" tabindex="-1">
				<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-gear" viewBox="0 0 16 16">
					<path d="M8 4.754a3.246 3.246 0 1 0 0 6.492 3.246 3.246 0 0 0 0-6.492zM5.754 8a2.246 2.246 0 1 1 4.492 0 2.246 2.246 0 0 1-4.492 0z"/>
					<path d="M9.796 1.343c-.527-1.79-3.065-1.79-3.592 0l-.094.319a.873.873 0 0 1-1.255.52l-.292-.16c-1.64-.892-3.433.902-2.54 2.541l.159.292a.873.873 0 0 1-.52 1.255l-.319.094c-1.79.527-1.79 3.065 0 3.592l.319.094a.873.873 0 0 1 .52 1.255l-.16.292c-.892 1.64.901 3.434 2.541 2.54l.292-.159a.873.873 0 0 1 1.255.52l.094.319c.527 1.79 3.065 1.79 3.592 0l.094-.319a.873.873 0 0 1 1.255-.52l.292.16c1.64.893 3.434-.902 2.54-2.541l-.159-.292a.873.873 0 0 1 .52-1.255l.319-.094c1.79-.527 1.79-3.065 0-3.592l-.319-.094a.873.873 0 0 1-.52-1.255l.16-.292c.893-1.64-.902-3.433-2.541-2.54l-.292.159a.873.873 0 0 1-1.255-.52l-.094-.319zm-2.633.283c.246-.835 1.428-.835 1.674 0l.094.319a1.873 1.873 0 0 0 2.693 1.115l.291-.16c.764-.415 1.6.42 1.184 1.185l-.159.292a1.873 1.873 0 0 0 1.116 2.692l.318.094c.835.246.835 1.428 0 1.674l-.319.094a1.873 1.873 0 0 0-1.115 2.693l.16.291c.415.764-.42 1.6-1.185 1.184l-.291-.159a1.873 1.873 0 0 0-2.693 1.116l-.094.318c-.246.835-1.428.835-1.674 0l-.094-.319a1.873 1.873 0 0 0-2.692-1.115l-.292.16c-.764.415-1.6-.42-1.184-1.185l.159-.291A1.873 1.873 0 0 0 1.945 8.93l-.319-.094c-.835-.246-.835-1.428 0-1.674l.319-.094A1.873 1.873 0 0 0 3.06 4.377l-.16-.292c-.415-.764.42-1.6 1.185-1.184l.292.159a1.873 1.873 0 0 0 2.692-1.115l.094-.319z"/>
				</svg>
			</button>
			<ul class="dropdown-menu">
				<xsl:apply-templates mode="comboboxButton:options" select=".">
					<xsl:with-param name="selection" select="$selection"/>
					<xsl:with-param name="items" select="$items"/>
				</xsl:apply-templates>
			</ul>
		</span>
	</xsl:template>

	<xsl:template mode="widget-attributes" match="px:Association/px:Entity/px:Routes/px:Route/@*">
		<xsl:attribute name="onclick">Promise.reject('Función no implementada')</xsl:attribute>
	</xsl:template>

	<xsl:template mode="widget-attributes" match="px:Association/px:Entity/px:Routes/px:Route[@Method='add']/@*">
		<!--<xsl:attribute name="onclick">px.navigateTo('#<xsl:value-of select="ancestor::px:Entity[1]/@Schema"/>/<xsl:value-of select="ancestor::px:Entity[1]/@Name"/>~add','')</xsl:attribute>-->
		<xsl:attribute name="href">
			<xsl:text/>#<xsl:value-of select="ancestor::px:Entity[1]/@Schema"/>/<xsl:value-of select="ancestor::px:Entity[1]/@Name"/>~add<xsl:text/>
		</xsl:attribute>
		<xsl:attribute name="xo-scope">disabled</xsl:attribute>
	</xsl:template>

	<xsl:template mode="widget-attributes" match="px:Association/px:Entity/px:Routes/px:Route[@Method='edit']/@*">
		<xsl:attribute name="onclick">px.editSelectedOption(selectSingleNode('ancestor::*[.//xhtml:select][1]//xhtml:select'))</xsl:attribute>
	</xsl:template>

	<xsl:template match="px:Entity[@control:type='combobox:control']/px:Routes/px:Route[@Method='add']/@*">
		<xsl:text>Crear nuevo</xsl:text>
	</xsl:template>

	<xsl:template match="px:Entity[@control:type='combobox:control']/px:Routes/px:Route[@Method='delete']/@*">
		<xsl:text>Borrar registro</xsl:text>
	</xsl:template>

	<xsl:template match="px:Entity[@control:type='combobox:control']/px:Routes/px:Route[@Method='edit']/@*">
		<xsl:text>Editar registro</xsl:text>
	</xsl:template>

	<xsl:template mode="comboboxButton:options" match="@*">
		<xsl:param name="context" select="node-expected"/>
		<xsl:param name="items" select="*"/>
		<xsl:variable name="id" select="ancestor-or-self::*[@xo:id][1]/@xo:id"/>
		<li onclick="px.refreshCatalog(this)">
			<a class="dropdown-item" href="#">Actualizar</a>
		</li>
		<xsl:apply-templates mode="widget" select="key('routes',concat(ancestor::px:Entity[1]/@xo:id,'::',name()))">
			<xsl:with-param name="context" select="."/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template mode="combobox:widget" match="@*">
		<xsl:param name="context" select="key('dataset', concat(ancestor::px:Entity[1]/@xo:id,'::',name()))"/>
		<xsl:param name="selection" select="."/>
		<xsl:param name="target" select="."/>
		<xsl:param name="class"></xsl:param>
		<xsl:variable name="schema" select="key('schema',concat(ancestor::px:Entity[1]/@xo:id,'::',name($selection)))/../px:Mappings/px:Mapping/@Referencee"/>
		<xsl:variable name="current" select="."/>
		<select class="form-select" xo-scope="{../@xo:id}" xo-slot="{name()}">
			<xsl:attribute name="style">
				<xsl:text/>min-width:<xsl:value-of select="concat(string-length($selection)+1,'ch')"/>;<xsl:text/>
			</xsl:attribute>
			<xsl:attribute name="onmouseover">scope.dispatch('downloadCatalog')</xsl:attribute>
			<xsl:apply-templates mode="combobox:attributes" select="."/>
			<xsl:choose>
				<xsl:when test="$context[local-name()='nil' and namespace-uri()='http://www.w3.org/2001/XMLSchema-instance'] or not($context|$selection[not($context)])">
					<option class="data-row" value="" xo-scope="none">Sin opciones</option>
				</xsl:when>
				<xsl:when test="$context">
					<xsl:apply-templates mode="combobox:previous-options" select=".">
						<xsl:sort select="../@meta:text"/>
						<xsl:with-param name="selection" select="$selection"/>
						<xsl:with-param name="schema" select="$schema"/>
					</xsl:apply-templates>
					<xsl:apply-templates mode="combobox:option" select="$context">
						<xsl:sort select="../@meta:text"/>
						<xsl:with-param name="selection" select="$selection"/>
						<xsl:with-param name="schema" select="$schema"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<!--<xsl:attribute name="style">cursor:wait</xsl:attribute>-->
					<xsl:apply-templates mode="combobox:option" select="$selection"/>
				</xsl:otherwise>
			</xsl:choose>
		</select>
	</xsl:template>

	<xsl:template mode="combobox:widget" match="@*">
		<xsl:param name="context" select="key('dataset', concat(ancestor::px:Entity[1]/@xo:id,'::',name()))"/>
		<xsl:param name="selection" select="."/>
		<xsl:param name="target" select="."/>
		<xsl:param name="class"></xsl:param>
		<xsl:variable name="schema" select="key('schema',concat(ancestor::px:Entity[1]/@xo:id,'::',name($selection)))/../px:Mappings/px:Mapping/@Referencee"/>
		<xsl:variable name="current" select="."/>
		<style>
			<![CDATA[
			.dropdown.form-input > button.form-control {
				height: calc(3.5rem + 2px);
			}
			
			.dropdown.form-input > button.form-control::after {
				left: 1.25rem;
				border-width: 0 1px 1px 0 !important;
				scale: 1.5;
				margin: auto;
				position: relative;
			}
			
			.form-floating>.form-control~label {
				opacity: .65;
				transform: scale(.85) translateY(-.5rem) translateX(.15rem);
			}
			
			.dropdown.form-input > .dropdown-menu {
				padding: 0;
				width: 100%;
				position: absolute;
				inset: 0px auto auto 0px;
				margin: 0px;/*
				transform: translate(0px, 0px);
				top: 57px !important;*/
			}
			
			option.hidden {
				display: none;
			}
			
			option.disabled {
				opacity: .65;
			}
			
			.dropdown.form-input input[type=text]:focus {
				color: silver !important
			}

			.combobox .dropdown-toggle:after {
				border: solid !important;
				border-width: 0 2px 2px 0 !important;
				display: inline-block !important;
				padding: 2px !important;
				transform: rotate( 45deg ) !important;
			}
			
			.combobox .dropdown-menu {
				box-shadow: var(--combobox-menu-boxshadow, var(--menu-boxshadow, 5px 5px 10px 2px rgb(0,0,0,.5)))
			}
			
			.combobox input[type=search]::-webkit-search-cancel-button {
				display: none;
			}
			
			]]>
		</style>
		<div class="dropdown form-input form-control combobox" style="
    min-width: 19ch;
    display: flex;
    position: relative;
    flex: 1 1 auto;
    width: 1%;
    padding: 0;
    height: calc(3.5rem + 3px);
    border: none !important;
">
			<xsl:attribute name="onmouseover">scope.dispatch('downloadCatalog')</xsl:attribute>
			<button class="btn btn-lg dropdown-toggle form-control" xo-static="@*" type="button" data-bs-toggle="dropdown" aria-expanded="false" style="display:flex; padding: 0; background: transparent; padding-right: 2.5rem; position: absolute; top: 0;" tabindex="-1" onfocus="this.querySelector('input').focus()">
				<div class="form-group form-floating input-group" style="min-width: calc(19ch + 6rem);border: none;">
					<xsl:variable name="data_rows" select="$context/ancestor-or-self::data:rows[1]"/>
					<input type="search" name="" class="form-control" autocomplete="off" aria-autocomplete="none" maxlength="" size="" value="{current()}" style="border: 0 solid transparent !important; background: transparent;" xo-scope="{$data_rows/@xo:id}" xo-slot="state:filter">
						<xsl:attribute name="onfocus">this.select(); parentNode.scope.dispatch('downloadCatalog')</xsl:attribute>
					</input>
				</div>
			</button>
			<xsl:variable name="options" select="$context|$schema/ancestor::px:Association[1]/@IsNullable[.=1]"/>
			<ul class="dropdown-menu" xo-static="@*" style="width: 100%;" aria-labelledby="dropdownMenuLink">
				<select class="form-select data-rows" xo-static="@*" xo-scope="{../@xo:id}" xo-slot="{name()}" size="10" tabindex="-1" onchange="xo.components.combobox.change()">
					<xsl:if test="count($options) &lt; 10">
						<xsl:attribute name="size">
							<xsl:value-of select="count($options) + 1"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:attribute name="style">
						<xsl:text/>min-width:<xsl:value-of select="concat(string-length($selection)+1,'ch')"/>;<xsl:text/>
					</xsl:attribute>
					<xsl:apply-templates mode="combobox:attributes" select="."/>
					<xsl:choose>
						<xsl:when test="$options[local-name()='nil' and namespace-uri()='http://www.w3.org/2001/XMLSchema-instance'] or not($options|$selection[not($options)])">
							<option class="data-row" value="" xo-scope="none">Sin opciones</option>
						</xsl:when>
						<xsl:when test="$options">
							<xsl:apply-templates mode="combobox:previous-options" select=".">
								<xsl:sort select="../@meta:text"/>
								<xsl:with-param name="selection" select="$selection"/>
								<xsl:with-param name="schema" select="$schema"/>
							</xsl:apply-templates>
							<xsl:apply-templates mode="combobox:option" select="$options">
								<xsl:sort select="../@meta:text"/>
								<xsl:with-param name="selection" select="$selection"/>
								<xsl:with-param name="schema" select="$schema"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<!--<xsl:attribute name="style">cursor:wait</xsl:attribute>-->
							<xsl:apply-templates mode="combobox:option" select="$selection"/>
						</xsl:otherwise>
					</xsl:choose>
				</select>
			</ul>
			<script>
				<![CDATA[
xo.components.combobox = xo.components.combobox || {};
xo.listener.on('blur::.combobox [type=search]', function () {
    if (!(this instanceof HTMLInputElement)) return;
    let srcElement = this;
    xo.delay(500).then(() => {
        if (document.activeElement instanceof HTMLInputElement && document.activeElement.closest('.dropdown') !== srcElement.closest('.dropdown')) {
            let dropdown = srcElement.closest('.dropdown');
            let toggler = dropdown && dropdown.querySelector("[data-bs-toggle]");
            if (toggler) {
                try {
                    toggler = (bootstrap.Dropdown.getOrCreateInstance(toggler))
                    toggler.hide();
                } catch (e) { }
            }
        }
    })
});

xo.components.combobox.focusin = function() {
    let srcElement = this;
	let opened_menus = [...document.querySelectorAll(`.combobox .dropdown-menu.show`)].filter(element => element.closest('.dropdown') != srcElement.closest('.dropdown'));
    for (let menu of opened_menus) {
		let dropdown = menu.closest('.dropdown')
        let toggler = dropdown && dropdown.querySelector("[data-bs-toggle]");
        if (toggler) {
            try {
                toggler = (bootstrap.Dropdown.getOrCreateInstance(toggler))
                toggler.hide();
            } catch (e) { }
        }
    }
}
xo.listener.on('focusin::.combobox [type=search],body', xo.components.combobox.focusin)

xo.components.combobox.filter = function (event) {
    let self = event.srcElement;
    let wrapper = self.closest('.dropdown');
    let dropdown = self.dropdown || new bootstrap.Dropdown(wrapper.querySelector('.dropdown-toggle'));
    self.dropdown = dropdown;
    let optionsList = self.ownerDocument.contains(self.optionsList) && self.optionsList || wrapper.querySelector('.dropdown-menu');
    self.optionsList = optionsList;
    dropdown.show();

    let inputField = event.srcElement;
    let options = optionsList.querySelectorAll("li,option");
    for (let option of options) {
        if (!inputField.value) {
            option.classList.remove("hidden");
        } else if (option.classList.contains("disabled")) {
            option.classList.add("hidden");
        } else if (option.textContent.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toLowerCase().includes(inputField.value.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toLowerCase())) {
            option.classList.remove("hidden");
        } else {
            option.classList.add("hidden");
        }
    }
    optionsList.classList.add("filtered");
}

xo.listener.on(`input::.combobox [type=search]`, xo.components.combobox.filter);

xo.components.combobox.change = function () {
    let srcElement = event.srcElement;
    let dropdown = srcElement.closest('.dropdown');
    let toggler = dropdown.querySelector("[data-bs-toggle]");
    try {
        if (toggler) {
            toggler = (bootstrap.Dropdown.getOrCreateInstance(toggler))
            toggler.hide();
        }
    } catch (e) { }
}

xo.components.combobox.keyup = function (event) {
    if ((event.ctrlKey || event.altKey) || !['ArrowDown', 'ArrowUp', 'Tab', 'Escape'].includes(event.key)) return;
    let self = event.srcElement;
    let wrapper = self.closest('.dropdown');
    let optionsList = self.optionsList || wrapper.querySelector('.dropdown-menu');
    self.optionsList = optionsList;

    filtered_options = optionsList.querySelectorAll("li, option").toArray().filter(option => !(option.style.display == 'none' || option.matches('.hidden')));

    if (event.key == 'Escape') {
        optionsList.classList.remove('show');
    } else {
        optionsList.classList.add('show');
    }
    let active_item = filtered_options.toArray().filter(option => option.disabled || option.classList.contains("disabled") || option.selected || option.classList.contains("active")).pop();
    let active_item_index = filtered_options.toArray().findIndex(option => option === active_item);
    if (event.key == 'ArrowDown') {
        ++active_item_index;
        active_item_index = active_item_index >= filtered_options.length ? filtered_options.length - 1 : active_item_index;
    } else if (event.key == 'ArrowUp') {
        --active_item_index;
        active_item_index = active_item_index < 0 ? 0 : active_item_index;
    }
    active_item = filtered_options[active_item_index];
    [...filtered_options].forEach(op => op.classList.remove("active"));
    active_item && active_item.classList.add("active");
    if (active_item instanceof HTMLOptionElement) active_item.selected = true;
    //if (event.key=='Tab') {
    //	active_item && active_item.click();
    //	/*active_item && active_item.closest('.autocomplete-box').scope.set(active_item.classList.contains//("disabled")? "" : active_item.textContent)*/
    //	optionsList.classList.remove('show');
    //}
};
xo.listener.on('input::.combobox [type=search]', xo.components.combobox.keyup)

xo.listener.on('input::.combobox [type=search]', function (event) {
    if (!['Tab', 'Enter'].includes(event.key)) return;
    let srcElement = event.srcElement;
    let dropdown = srcElement.closest('.dropdown');
    let scope = dropdown && dropdown.scope;
    let optionsList = dropdown && dropdown.querySelector('.dropdown-menu.show');
    if (!(optionsList && scope)) return;
    let toggler = dropdown.querySelector("[data-bs-toggle]");
    toggler && new bootstrap.Dropdown(toggler).hide();
    let input = dropdown.querySelector('input');
    let active_item = optionsList.querySelectorAll("li, option").toArray().filter(option => !(option.disabled || option.classList.contains("disabled")) && (option.selected || option.classList.contains("active"))).pop();
    if (active_item) scope.set(active_item.scope);
    if (input === input.ownerDocument.activeElement) input.blur();
})

xo.listener.on('click::.dropdown li', function () {
    let active_item = this;
    active_item && active_item.closest('.autocomplete-box').scope.set(active_item.classList.contains("disabled") ? "" : active_item.textContent);
    optionsList.classList.remove('show');
})
		]]>
			</script>
		</div>
	</xsl:template>

	<xsl:template mode="combobox:previous-options" match="@*">
		<option value="" xo-scope="none" class="disabled data-row">
			Selecciona...
		</option>
	</xsl:template>

	<xsl:template mode="combobox:option-text" match="@*">
		<xsl:apply-templates select="."/>
	</xsl:template>

	<xsl:template mode="combobox:option-text" match="@*[.='']">
		<xsl:text/>Sin opciones...<xsl:text/>
	</xsl:template>

	<xsl:template mode="combobox:option-text" match="@IsNullable[.=1]">
		<xsl:text/>Sin asignar<xsl:text/>
	</xsl:template>

	<xsl:template mode="combobox:option-value" match="@IsNullable[.=1]">
		<xsl:text/>null<xsl:text/>
	</xsl:template>

	<xsl:template mode="combobox:option" match="@*">
		<xsl:param name="selection" select="node-expected|current()"/>
		<xsl:param name="schema" select="current()"/>
		<xsl:variable name="current" select="current()"/>
		<option class="data-row" xo-scope="{../@xo:id}">
			<xsl:variable name="differences">
				<xsl:for-each select="$schema">
					<xsl:if test="$current/../@*[name()=current()]!=$selection/../@*[name()=current()/../@Referencer]">1</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:if test="not(parent::xo:r)">
				<xsl:attribute name="xo-slot">
					<xsl:value-of select="name()"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="value">
				<xsl:apply-templates mode="combobox:option-value" select="."/>
			</xsl:attribute>
			<xsl:if test="$differences = ''">
				<xsl:attribute name="selected"/>
			</xsl:if>
			<xsl:apply-templates mode="combobox:option-text" select="."/>
		</option>
	</xsl:template>
</xsl:stylesheet>