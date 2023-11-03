/* adapted from: https://open-props.style/ 
const getColorPreference = () => {
    if (localStorage.getItem('theme-preference'))
        return localStorage.getItem('theme-preference')
    else
        return window.matchMedia('(prefers-color-scheme: dark)').matches
            ? 'dark'
            : 'light'
}

const setPreference = () => {
    localStorage.setItem('theme-preference', theme.value)
    reflectPreference()
}

const reflectPreference = () => {
    document.firstElementChild.setAttribute('data-theme', theme.value)
    document.firstElementChild.setAttribute('data-bs-theme', theme.value)
    document.querySelector('.theme-toggle')?.setAttribute('aria-label', theme.value)
}

const theme = {
    value: getColorPreference(),
}

reflectPreference()

window.onload = () => {
    reflectPreference()
}

window
    .matchMedia('(prefers-color-scheme: dark)')
    .addEventListener('change', ({ matches: isDark }) => {
        theme.value = isDark ? 'dark' : 'light'
        setPreference()
    })*/
/*!
* Color mode toggler for Bootstrap's docs (https://getbootstrap.com/)
* Copyright 2011-2023 The Bootstrap Authors
* Licensed under the Creative Commons Attribution 3.0 Unported License.
*/

const getStoredTheme = () => localStorage.getItem('theme')
const setStoredTheme = theme => localStorage.setItem('theme', theme)

const getPreferredTheme = () => {
    const storedTheme = getStoredTheme()
    if (storedTheme) {
        return storedTheme
    }

    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
}

const setTheme = theme => {
    if (theme === 'auto' && window.matchMedia('(prefers-color-scheme: dark)').matches) {
        document.documentElement.setAttribute('data-bs-theme', 'dark')
        document.documentElement.setAttribute('data-theme', 'dark')
    } else {
        document.documentElement.setAttribute('data-bs-theme', theme)
        document.documentElement.setAttribute('data-theme', theme)
    }
}

setTheme(getPreferredTheme())

const showActiveTheme = (theme, focus = false) => {
    const themeSwitcher = document.querySelector('#bd-theme')

    if (!themeSwitcher) {
        return
    }

    const themeSwitcherText = document.querySelector('#bd-theme-text') || document.createElement("p")
    const activeThemeIcon = document.querySelector('.theme-icon-active use') || document.createElement("p")
    const btnToActive = document.querySelector(`[data-bs-theme-value="${theme}"]`) || document.createElement("p")
    const svgOfActiveBtn = btnToActive.querySelector('svg use').getAttribute('href')

    document.querySelectorAll('[data-bs-theme-value]').forEach(element => {
        element.classList.remove('active')
        element.setAttribute('aria-pressed', 'false')
    })

    btnToActive.classList.add('active')
    btnToActive.setAttribute('aria-pressed', 'true')
    activeThemeIcon.setAttribute('href', svgOfActiveBtn)
    const themeSwitcherLabel = `${themeSwitcherText.textContent} (${btnToActive.dataset.bsThemeValue})`
    themeSwitcher.setAttribute('aria-label', themeSwitcherLabel)

    if (focus) {
        themeSwitcher.focus()
    }
}

window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
    const storedTheme = getStoredTheme()
    if (storedTheme !== 'light' && storedTheme !== 'dark') {
        setTheme(getPreferredTheme())
    }
})
xo.listener.on(['click::.theme-toggle, .theme-toggle *'], function () {
    const theme = (this.closest("[data-bs-theme-value]") || document.createElement("p")).getAttribute("data-bs-theme-value")
    if (!theme) return;
    setStoredTheme(theme)
    setTheme(theme)
    showActiveTheme(theme, true)
})
