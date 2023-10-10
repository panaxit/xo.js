<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xo="http://panax.io/xover"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:control="http://www.w3.org/2001/XMLSchema-instance"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:custom="http://panax.io/custom"
  xmlns:data="http://panax.io/source"
  xmlns:meta="http://panax.io/metadata"
  xmlns:autocompleteBox="http://panax.io/widget/autocompleteBox"
  xmlns:autocompleteBoxButton="http://panax.io/widget/autocompleteBox-button"
  xmlns:px="http://panax.io/entity"
  exclude-result-prefixes="xo xsl autocompleteBox data px"
>
	<xsl:import href="keys.xslt"/>
	<xsl:key name="autocompleteBox:widget" match="node-expected" use="@xo:id"/>

	<xsl:template mode="widget-attributes" match="@*" priority="-1"/>

	<xsl:template mode="autocompleteBox:attributes" match="@*" priority="-1">
		<xsl:apply-templates mode="widget-attributes" select="."/>
	</xsl:template>

	<xsl:template mode="autocompleteBox:preceding-siblings" match="@*" priority="-1"></xsl:template>

	<xsl:template mode="autocompleteBox:following-siblings" match="@*" priority="-1"></xsl:template>

	<xsl:template mode="autocompleteBoxButton:widget" match="@*">
		<xsl:param name="selection" select="node-expected"/>
		<xsl:param name="items" select="ancestor-or-self::*[1]"/>
		<xsl:variable name="id" select="ancestor-or-self::*[@xo:id][1]/@xo:id"/>
		<span class="input-group-append" style="color:black;" xo-scope="{$id}">
			<button type="button" class="btn btn-secondary btn-lg dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false" tabindex="-1">
				<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-gear" viewBox="0 0 16 16">
					<path d="M8 4.754a3.246 3.246 0 1 0 0 6.492 3.246 3.246 0 0 0 0-6.492zM5.754 8a2.246 2.246 0 1 1 4.492 0 2.246 2.246 0 0 1-4.492 0z"/>
					<path d="M9.796 1.343c-.527-1.79-3.065-1.79-3.592 0l-.094.319a.873.873 0 0 1-1.255.52l-.292-.16c-1.64-.892-3.433.902-2.54 2.541l.159.292a.873.873 0 0 1-.52 1.255l-.319.094c-1.79.527-1.79 3.065 0 3.592l.319.094a.873.873 0 0 1 .52 1.255l-.16.292c-.892 1.64.901 3.434 2.541 2.54l.292-.159a.873.873 0 0 1 1.255.52l.094.319c.527 1.79 3.065 1.79 3.592 0l.094-.319a.873.873 0 0 1 1.255-.52l.292.16c1.64.893 3.434-.902 2.54-2.541l-.159-.292a.873.873 0 0 1 .52-1.255l.319-.094c1.79-.527 1.79-3.065 0-3.592l-.319-.094a.873.873 0 0 1-.52-1.255l.16-.292c.893-1.64-.902-3.433-2.541-2.54l-.292.159a.873.873 0 0 1-1.255-.52l-.094-.319zm-2.633.283c.246-.835 1.428-.835 1.674 0l.094.319a1.873 1.873 0 0 0 2.693 1.115l.291-.16c.764-.415 1.6.42 1.184 1.185l-.159.292a1.873 1.873 0 0 0 1.116 2.692l.318.094c.835.246.835 1.428 0 1.674l-.319.094a1.873 1.873 0 0 0-1.115 2.693l.16.291c.415.764-.42 1.6-1.185 1.184l-.291-.159a1.873 1.873 0 0 0-2.693 1.116l-.094.318c-.246.835-1.428.835-1.674 0l-.094-.319a1.873 1.873 0 0 0-2.692-1.115l-.292.16c-.764.415-1.6-.42-1.184-1.185l.159-.291A1.873 1.873 0 0 0 1.945 8.93l-.319-.094c-.835-.246-.835-1.428 0-1.674l.319-.094A1.873 1.873 0 0 0 3.06 4.377l-.16-.292c-.415-.764.42-1.6 1.185-1.184l.292.159a1.873 1.873 0 0 0 2.692-1.115l.094-.319z"/>
				</svg>
			</button>
			<ul class="dropdown-menu">
				<xsl:apply-templates mode="autocompleteBoxButton:widget-options" select=".">
					<xsl:with-param name="selection" select="$selection"/>
					<xsl:with-param name="items" select="$items"/>
				</xsl:apply-templates>
			</ul>
		</span>
	</xsl:template>

	<xsl:template mode="autocompleteBoxButton:widget-options" match="@*">
		<xsl:param name="selection" select="node-expected"/>
		<xsl:param name="items" select="*"/>
		<xsl:variable name="id" select="ancestor-or-self::*[@xo:id][1]/@xo:id"/>
		<li onclick="scope.$$('descendant-or-self::data:rows[1]').remove()">
			<a class="dropdown-item" href="#">Actualizar</a>
		</li>
		<li>
			<a class="dropdown-item" href="javascript:void(0)" onclick="px.navigateTo('#{ancestor::px:Entity[1]/@Schema}/{ancestor::px:Entity[1]/@Name}~add','')">Crear Nuevo</a>
		</li>
		<xsl:if test="string($selection)!=''">
			<li>
				<a class="dropdown-item" href="javascript:void(0)" onclick="px.editSelectedOption(selectSingleNode('ancestor::*[xhtml:select]/xhtml:select'))">
					Editar registro
				</a>
			</li>
		</xsl:if>
	</xsl:template>

	<xsl:key name="referencer" match="px:Association/px:Mappings/px:Mapping/@Referencer" use="concat(ancestor::px:Entity[1]/@xo:id,'::',ancestor::px:Association[1]/@AssociationName)"/>
	<xsl:key name="referencee" match="px:Association/px:Mappings/px:Mapping/@Referencee" use="concat(ancestor::px:Association[1]/@xo:id,'::',.)"/>
	<xsl:key name="mapping" match="px:Association/px:Mappings/px:Mapping" use="concat(ancestor::px:Association[1]/@xo:id,'::',@Referencer,'::',@Referencee)"/>
	<xsl:template mode="autocompleteBox:widget" match="@*">
		<xsl:param name="dataset" select="key('dataset', concat(ancestor::px:Entity[1]/@xo:id,'::',name()))"/>
		<xsl:param name="selection" select="."/>
		<xsl:param name="target" select="."/>
		<xsl:param name="class"></xsl:param>
		<xsl:variable name="current" select="."/>
		<input type="text" class="form-control dropdown-toggle" xo-scope="{../@xo:id}" xo-slot="search:{local-name()}" autocomplete="off" onblur="this.value='{.}'; /*nextElementSibling.querySelector('ul').style.display='none';*/" onfocus="px.loadData(scope.parentNode.$(`ancestor-or-self::px:Entity[1]/px:Record/px:Association[@AssociationName='{local-name()}']/px:Entity`)); nextElementSibling.querySelector('ul').classList.toggle('show'); this.value=(this.scope.value || this.value); this.scope.value &amp;&amp; filterOptions(); this.select()" oninput="filterOptions()" style="position: relative" value="{.}">
			<xsl:attribute name="style">
				<xsl:text/>min-width:<xsl:value-of select="concat(string-length($selection)+1,'ch')"/>;<xsl:text/>
			</xsl:attribute>
			<xsl:apply-templates mode="autocompleteBox:attributes" select="."/>
		</input>
		<span class="autocomplete-box" xo-scope="{../@xo:id}" xo-slot="{name()}" onclick="this.querySelector('ul').classList.toggle('show')">
			<xsl:attribute name="onmouseover">px.loadData(scope.$(`ancestor::px:Entity[1]/px:Record/px:Association[@AssociationName="${scope.localName}"]/px:Entity`))</xsl:attribute>
			<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-chevron-down" viewBox="0 0 16 16">
				<path fill-rule="evenodd" d="M1.646 4.646a.5.5 0 0 1 .708 0L8 10.293l5.646-5.647a.5.5 0 0 1 .708.708l-6 6a.5.5 0 0 1-.708 0l-6-6a.5.5 0 0 1 0-.708z"/>
			</svg>
			<ul id="datalist_{../@xo:id}_{local-name()}" class="dropdown-menu dropdown-menu-end" aria-labelledby="dropdownMenuLink" data-bs-popper="none">
				<xsl:choose>
					<xsl:when test="$dataset[local-name()='nil' and namespace-uri()='http://www.w3.org/2001/XMLSchema-instance'] or not($dataset|$selection[not($dataset)])">
						<li value="" class="dropdown-item">Sin opciones</li>
					</xsl:when>
					<xsl:when test="$dataset">
						<xsl:apply-templates mode="autocompleteBox:previous-options" select=".">
							<xsl:sort select="../@meta:text"/>
							<xsl:with-param name="selection" select="$selection"/>
						</xsl:apply-templates>
						<xsl:apply-templates mode="autocompleteBox:option" select="$dataset">
							<xsl:sort select="../@meta:text"/>
							<xsl:with-param name="referencer" select="$selection"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="style">cursor:wait</xsl:attribute>
						<li class="dropdown-item">
							<xsl:apply-templates select="$selection"/>
						</li>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:apply-templates mode="autocompleteBox:following-siblings" select=".">
					<xsl:with-param name="catalog" select="$dataset"/>
				</xsl:apply-templates>
			</ul>
			<script>
				<![CDATA[
		function filterOptions() {
			//	console.assert(false)
			let inputField = event.srcElement;
			let optionsList = inputField.nextElementSibling.querySelector("ul");
			optionsList.style.width = inputField.parentNode.clientWidth+'px';
			let options = optionsList.getElementsByTagName("li");
			filtered_options = []
			for (let option of options) {
				//if (option.textContent.toLowerCase().includes(inputField.value.toLowerCase())) {
					option.style.display = "block";
					filtered_options.push(option);
				//} else {
				//	option.style.display = "none";
				//}
			}
			return filtered_options;
		}

        let optionsList = top.document.getElementById("datalist_]]><xsl:value-of select="concat(../@xo:id,'_',local-name())"/><![CDATA[");
		let inputField = optionsList.parentNode.previousElementSibling;
		optionsList.style.width = inputField.parentNode.clientWidth+'px';
        let options = optionsList.getElementsByTagName("li");
		inputField.addEventListener("keydown", (event) => {
			if (!['ArrowDown','ArrowUp','Tab','Escape'].includes(event.key)) return null;
            filtered_options = filterOptions();
			let active_item_index = filtered_options.findIndex(op => op.classList.contains("active"));
			if (event.key=='Escape') {
				optionsList.classList.remove('show');
			}
            if (event.key=='ArrowDown') {
				++ active_item_index;
				active_item_index = active_item_index >= filtered_options.length ? filtered_options.length - 1 : active_item_index;
			}
            if (event.key=='ArrowUp') {
				-- active_item_index;
				active_item_index = active_item_index < 0 ? 0 : active_item_index;
			}
			let active_item = filtered_options[active_item_index];
			[...options].forEach(op => op.classList.remove("active"));
			active_item && active_item.classList.add("active");
            if (event.key=='Tab') {
				active_item && active_item.click();
				/*active_item && active_item.closest('.autocomplete-box').scope.set(active_item.classList.contains("disabled")? "" : active_item.textContent)*/
				optionsList.classList.remove('show');
			}
			//console.log(event.key+': '+active_item.textContent)
        });
		
		inputField.addEventListener("input", (event) => {
            filterOptions();
        });

        for (let option of options) {
			option.addEventListener("click", () => {
				let active_item = option;
				active_item && active_item.closest('.autocomplete-box').scope.set(active_item.classList.contains("disabled") ? "" : active_item.textContent);
				optionsList.classList.remove('show');
			});
        }
			]]>
			</script>
		</span>
	</xsl:template>

	<xsl:template mode="autocompleteBox:previous-options" match="@*">
		<li class="dropdown-item disabled" value="">
			<xsl:text/>Selecciona...<xsl:text/>
		</li>
	</xsl:template>

	<xsl:template mode="autocompleteBox:option" match="@*">
		<xsl:param name="referencer" select="node-expected|current()"/>
		<li class="dropdown-item" xo-scope="{../@xo:id}">
			<xsl:variable name="selected">
				<xsl:choose>
					<xsl:when test="current() = $referencer">true</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="$selected = 'true'">
				<xsl:attribute name="selected"/>
			</xsl:if>
			<xsl:apply-templates select="."/>
		</li>
	</xsl:template>
</xsl:stylesheet>