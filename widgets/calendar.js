xo.listener.on(`appendTo::px:Entity[@controlType="calendar"]/data:rows`, function ({ store, node }) {
    let fechas = this.select("x:r/@Fecha").filter(fecha => fecha.value).map(fecha => new Date(fecha.value + 'T00:00:00'));
    if (!fechas.length) return;
    var maxDate = new Date(Math.max.apply(null, fechas));
    var minDate = new Date(Math.min.apply(null, fechas));
    let month = minDate.getMonth() + 1;
    this.ownerDocument.selectFirst("//dias").setAttribute("state:current_month", minDate.getFullYear() + '-' + ('0' + month).substr(-2, 2))
})

xo.listener.on(`beforeTransform::px:Entity[@controlType="calendar"][@env:stylesheet="px-Entity.xslt"]`, function ({ store, node }) {
    let target_node = this.selectFirst("px:Entity/dias");
    let [year, month] = target_node.getAttribute("state:current_month").split('-');
    let dias = xo.xml.createNode(`<dias state:current_month="${year}-${('0' + month).substr(-2, 2)}">${dateRange(new Date(year, month - 1, 1).toJSON().substring(0, 10)).map(el => xo.xml.createNode(`<dia value="${el.toJSON().substring(0, 10)} 00:00:00" text="${el.getDate()}" week="${el.getWeek()}"/>`)).join('')}</dias>`)
    target_node.append(...dias.childNodes);
})

xo.listener.on(`fetch::px:Entity`, function ({ store, node }) {
    if (this.documentElement.matches(`*[@controlType="calendar"]`)) {
        this.documentElement.append(xo.xml.createNode(`<labels>
		<meses>
			<mes value="01">Enero</mes>
			<mes value="02">Febrero</mes>
			<mes value="03">Marzo</mes>
			<mes value="04">Abril</mes>
			<mes value="05">Mayo</mes>
			<mes value="06">Junio</mes>
			<mes value="07">Julio</mes>
			<mes value="08">Agosto</mes>
			<mes value="09">Septiembre</mes>
			<mes value="10">Octubre</mes>
			<mes value="11">Noviembre</mes>
			<mes value="12">Diciembre</mes>
		</meses>
		<diaSemana>
			<dia>Semana</dia>
			<dia>Domingo</dia>
			<dia>Lunes</dia>
			<dia>Martes</dia>
			<dia>Miercoles</dia>
			<dia>Jueves</dia>
			<dia>Viernes</dia>
			<dia>Sabado</dia>
		</diaSemana>
	</labels>`))
        var date = new Date();
        let month = date.getMonth() + 1;
        let year = date.getFullYear();
        this.documentElement.append(xo.xml.createNode(`<dias state:current_month="${year}-${('0' + month).substr(-2, 2)}"/>`));
    }
})

function moveMonth(attr, interval = { m: 1 }) {
    let date = new Date(attr.value + '-01T00:00:00');
    date.setMonth(date.getMonth() + interval.m);
    date.setDate(1)
    attr.set(date.toJSON().substring(0, 7));
}

function dateRange(date = Date.now(), range = { m: 1 }) {
    let first_date = new Date(`${date}T00:00:00`);
    let dates = getDates(first_date, new Date(first_date).setMonth(first_date.getMonth() + (range.m || 0)) - 1);
    dates = getDates(dates[0].addDays(-dates[0].getDay()), dates[0].addDays(-1)).concat(dates);
    dates = dates.concat(getDates(dates[dates.length - 1].addDays(1), dates[dates.length - 1].addDays(6 - dates[dates.length - 1].getDay())));
    return dates;
}

function getDates(startDate, stopDate) {
    var dateArray = new Array();
    var currentDate = startDate;
    while (currentDate <= stopDate) {
        dateArray.push(new Date(currentDate));
        currentDate = currentDate.addDays(1);
    }
    return dateArray;
}

function weekNumber(date) {
    let startDate = new Date(date.getFullYear(), 0, 1);
    let days = Math.floor((date - startDate) /
        (24 * 60 * 60 * 1000));

    return Math.ceil(date.getDay() + 1 + days / 7);
}

Date.prototype.getWeek = function () {
    var onejan = new Date(this.getFullYear(), 0, 1);
    return Math.ceil((((this - onejan) / 86400000) + onejan.getDay() + 1) / 7);
};