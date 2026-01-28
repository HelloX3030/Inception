let cookies = 0;
let cookiesPerClick = 1;
let autoClickers = 0;
let level = 1;

let clickCost = 10;
let autoCost = 50;

// Load save
const save = JSON.parse(localStorage.getItem("cookieSave"));
if (save) {
    cookies = save.cookies;
    cookiesPerClick = save.cpc;
    autoClickers = save.auto;
    level = save.level;
    clickCost = save.clickCost;
    autoCost = save.autoCost;
}

const cookiesEl = document.getElementById("cookies");
const cpcEl = document.getElementById("cpc");
const levelEl = document.getElementById("level");
const clickCostEl = document.getElementById("click-cost");
const autoCostEl = document.getElementById("auto-cost");

function updateUI() {
    cookiesEl.textContent = Math.floor(cookies);
    cpcEl.textContent = cookiesPerClick;
    levelEl.textContent = level;
    clickCostEl.textContent = clickCost;
    autoCostEl.textContent = autoCost;
}

// Cookie click
document.getElementById("cookie").addEventListener("click", () => {
    cookies += cookiesPerClick;
    checkLevelUp();
    updateUI();
});

// Upgrade click power
document.getElementById("upgrade-click").addEventListener("click", () => {
    if (cookies >= clickCost) {
        cookies -= clickCost;
        cookiesPerClick++;
        clickCost = Math.floor(clickCost * 1.6);
        updateUI();
    }
});

// Buy auto clicker
document.getElementById("upgrade-auto").addEventListener("click", () => {
    if (cookies >= autoCost) {
        cookies -= autoCost;
        autoClickers++;
        autoCost = Math.floor(autoCost * 2);
        updateUI();
    }
});

// Auto production
setInterval(() => {
    cookies += autoClickers;
    checkLevelUp();
    updateUI();
}, 1000);

// Level system
function checkLevelUp() {
    const nextLevel = level * 100;
    if (cookies >= nextLevel) {
        level++;
        cookiesPerClick += 2;
    }
}

// Auto-save
setInterval(() => {
    localStorage.setItem("cookieSave", JSON.stringify({
        cookies,
        cpc: cookiesPerClick,
        auto: autoClickers,
        level,
        clickCost,
        autoCost
    }));
}, 3000);

updateUI();
