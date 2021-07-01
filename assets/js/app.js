// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import 'nouislider/distribute/nouislider.css';
import "../css/app.css";
// import "../node_modules/leaflet/dist/leaflet.css";
// import '../node_modules/leaflet.markercluster/dist/MarkerCluster.css';
// import '../node_modules/leaflet.markercluster/dist/MarkerCluster.Default.css';

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import { Socket } from "phoenix"
import NProgress from "nprogress"
import { LiveSocket } from "phoenix_live_view"
import smoothscroll from 'smoothscroll-polyfill'
import 'alpinejs'
// this work good -> // import IMask from 'imask';
// TODO should dleete form file lader o url loader and magic alpine in npm 
// imports only factory
import IMask from 'imask/esm/imask';
// add needed features
import 'imask/esm/masked/pattern';
import 'imask/esm/masked/number';
import noUiSlider from 'nouislider';
import wNumb from 'wnumb';

import './leaflet/leaflet-map';
import './leaflet/leaflet-marker';
import './leaflet/leaflet-icon';

smoothscroll.polyfill();

const Hooks = {}

Hooks.Modal = {
  mounted() {
    document.body.classList.add("h-full");
    document.body.classList.add("overflow-hidden");
  },
  destroyed() {
    document.body.classList.remove("h-full");
    document.body.classList.remove("overflow-hidden");
  }
}

Hooks.InfiniteScroll = {
  mounted() {
    const loadMore = this.el.dataset.loadMore;
    this.observer = new IntersectionObserver(entries => {
      const entry = entries[0];
      if (entry.isIntersecting && loadMore) {
        this.el.click()
      }
    });

    this.observer.observe(this.el);
  },
  destroyed() {
    this.observer.disconnect();
  },
};

Hooks.PriceSlider = {
  min_price() {
    return document.getElementById("min_price")
  },
  max_price() {
    return document.getElementById("max_price")
  },
  slider() {
    price_slider = noUiSlider.create(this.el, {
      start: [this.el.dataset.min_price, this.el.dataset.max_price],
      behaviour: 'drag-tap',
      connect: true,
      pips: {
        mode: 'values',
        values: [0, 10_000],
        density: 4
      },
      tooltips: true,
      format: wNumb({
        decimals: 0
      }),
      range: {
        'min': 0,
        'max': 10_000
      }
    })
    price_slider.on('update', (values, handle) => {
      [this.min_price(), this.max_price()][handle].value = values[handle];
      // .value = value; 
    })
    price_slider.on('end', (prices) => {
      this.pushEventTo("#" + this.min_price().form.id, 'price_change', prices)
    })
    return this.el
  },

  mounted() {
    this.slider();
    // this.el.noUiSlider.set([this.el.dataset.min_price, this.el.dataset.max_price])
    this.min_price().onchange = (el) => {
      this.el.noUiSlider.set([el.target.value, null])
    };
    this.max_price().onchange = (el) => {
      this.el.noUiSlider.set([null, el.target.value])
    };
    console.log("i am in mounted")
  },
  // updatePrice(hook, event) {      
  //     hook.pushEvent('filter', {"_target": ["price"], "price": event})
  //   console.log("event", event)
  // },
  updated() {
    // this.el.noUiSlider.set([this.el.dataset.min_price, this.el.dataset.max_price])
    console.log("i am in update")
  },
  destroyed() {
    console.log("i am in desctoy")
  }
}

Hooks.PhoneNumber = {
  phoneMask() {
    return (
      IMask(this.el, {
        mask: '+{7}(000) 000-00-00',
        lazy: false,  // make placeholder always visible
      })
    )
  },
  mounted() {
    this.phoneMask().updateValue()
  },
  updated() {
    this.phoneMask().updateValue()
  },
  destroyed() {
    this.phoneMask().destroy()
  }
};

Hooks.Mobile = {
  mounted() {
    if (window.outerWidth > 768) { this.el.remove() }
  },
  updated() {
    if (window.outerWidth > 768) { this.el.remove() }
  },
}

Hooks.Desktop = {
  mounted() {
    if (window.outerWidth < 768) { this.el.remove() }
  },
  updated() {
    if (window.outerWidth < 768) { this.el.remove() }
  },
}

Hooks.StockCartNumberInput = {
  numberInput() {
    return (
      IMask(this.el, {
        mask: Number,
        min: 1,
        max: this.el.dataset.max_quantity,
        signed: false
      })
    )
  },
  // decrement() {
  //   this.numberInput().typedValue -= 1
  // },
  // increment() {
  //   this.numberInput().typedValue += 1
  // },
  mounted() {
    // window.StockCartNumberInputHook = this
    this.numberInput().updateValue()
  },
  updated() {
    this.numberInput().updateValue()
  },
  destroyed() {
    this.numberInput().destroy()
  }
};

Hooks.NumberInput = {
  numberInput() {
    return (
      IMask(this.el, {
        mask: Number,
        min: 0,
        max: 100000
      })
    )
  },
  mounted() {
    this.numberInput().updateValue()
  },
  updated() {
    this.numberInput().updateValue()
  },
  destroyed() {
    this.numberInput().destroy()
  }
};

function detectDevice() {
  if (window.innerWidth < 768) {
    return "mobile"
  } else if (window.innerWidth < 1280) {
    return "tablet"
  } else {
    return "desktop"
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  dom: {
    onBeforeElUpdated(from, to) {
      if (from.__x) {
        window.Alpine.clone(from.__x, to)
      }
    }
  },
  params: { _csrf_token: csrfToken, device: detectDevice() },
  hooks: Hooks
})


let html = document.querySelector('html');
let themeBtn = document.getElementById("colorTheme")

// theme button

// On page load or when changing themes, best to add inline in `head` to avoid FOUC
if (localStorage.theme === 'dark' || (!'theme' in localStorage && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
  html.classList.add('dark')
} else {
  html.classList.remove('dark')
}

function toggleDarkMode() {
  if (html.classList.contains('dark')) {
    html.classList.remove('dark');
    localStorage.theme = 'light'
  } else {
    html.classList.add('dark');
    localStorage.theme = 'dark'

  }
}

themeBtn && themeBtn.addEventListener("click", toggleDarkMode)

// Whenever the user explicitly chooses to respect the OS preference
// localStorage.removeItem('theme') should uncommetn


// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket


