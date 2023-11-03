<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
xmlns:component="http://xover.dev/component"
>
	<xsl:template mode="component:theme-toggler" match="@*|*">
		<script src="/widgets/theme-toggle.js"></script>
		<style>
			<![CDATA[
        @import "https://unpkg.com/open-props/animations.min.css";
        @media (prefers-color-scheme: dark) {
            :where(textarea,select,input:not([type="button"],[type="submit"],[type="reset"])) {
                background-color: #171a1c
            }

            :where(dialog) {
                background-color: var(--surface-2)
            }

            :where(html) {
                --shadow-strength: 10%;
                --shadow-color: 220 40% 2%
            }

            ::placeholder {
                color: var(--gray-6)
            }
        }

        :where([data-theme="light"],.light,.light-theme) {
            color-scheme: light;
            --link: var(--indigo-7);
            --link-visited: var(--purple-7);
            --text-1: var(--gray-9);
            --text-2: var(--gray-7);
            --surface-1: var(--gray-0);
            --surface-2: var(--gray-2);
            --surface-3: var(--gray-3);
            --surface-4: var(--gray-4);
            --scrollthumb-color: var(--gray-7);
            --shadow-color: 220 3% 15%;
            --shadow-strength: 1%
        }

        [data-theme=light] {
            --nav-icon: var(--gray-7);
            --nav-icon-hover: var(--gray-9)
        }

        [data-theme=dark] {
            --nav-icon: var(--gray-5);
            --nav-icon-hover: var(--gray-2)
        }

        #moon, #sun {
            fill: var(--nav-icon);
            stroke: none
        }

        :hover > svg > #moon, :hover > svg > #sun {
            fill: var(--nav-icon-hover)
        }

        #sun {
            transition: transform .5s var(--ease-4);
            transform-origin: center center
        }

        #sun-beams {
            --_opacity-dur: .15s;
            stroke: var(--nav-icon);
            stroke-width: 2px;
            transform-origin: center center;
            transition: transform .5s var(--ease-elastic-4),opacity var(--_opacity-dur) var(--ease-3)
        }

        :hover > svg > #sun-beams {
            stroke: var(--nav-icon-hover)
        }

        #moon > circle {
            transition: transform .5s var(--ease-out-3)
        }

        [data-theme=light] #sun {
            transform: scale(.5)
        }

        [data-theme=light] #sun-beams {
            transform: rotate(.25turn);
            --_opacity-dur: .5s
        }

        [data-theme=dark] #moon > circle {
            transform: translate(-20px)
        }

        [data-theme=dark] #sun-beams {
            opacity: 0
        }
]]>
		</style>
		<link rel="stylesheet" href="https://unpkg.com/open-props" />
		<button class="theme-toggle" title="Toggles light &amp; dark" aria-label="dark" aria-live="polite">
			<xsl:apply-templates mode="component:theme-toggler-icon" select="."/>
		</button>
	</xsl:template>

	<xsl:template mode="component:theme-toggler-icon" match="@*|*">
		<svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" width="16" height="16" viewBox="0 0 16 16">
			<!-- https://feathericons.com/?query=sun -->
			<mask id="moon">
				<rect x="0" y="0" width="100%" height="100%" fill="white"></rect>
				<circle cx="40" cy="8" r="11" fill="black"></circle>
			</mask>
			<circle id="sun" cx="12" cy="12" r="11" mask="url(#moon)"></circle>
			<g id="sun-beams">
				<line x1="12" y1="1" x2="12" y2="3"></line>
				<line x1="12" y1="21" x2="12" y2="23"></line>
				<line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
				<line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
				<line x1="1" y1="12" x2="3" y2="12"></line>
				<line x1="21" y1="12" x2="23" y2="12"></line>
				<line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
				<line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
			</g>
		</svg>		
	</xsl:template>
</xsl:stylesheet>
