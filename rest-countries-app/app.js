// Tailwind custom configuration
tailwind.config = {
    darkMode: 'class',
    theme: {
        extend: {
            colors: {
                'dark-blue-dark-element': 'hsl(209, 23%, 22%)',
                'very-dark-blue-dark-bg': 'hsl(207, 26%, 17%)',
                'very-dark-blue-light-text': 'hsl(200, 15%, 8%)',
                'dark-gray-light-input': 'hsl(0, 0%, 52%)',
                'very-light-gray-light-bg': 'hsl(0, 0%, 98%)',
                'white': 'hsl(0, 0%, 100%)',
            },
            fontFamily: {
                'nunito': ['"Nunito Sans"', 'sans-serif'],
            },
        },
    },
};

// Theme management with dark mode functionality
document.addEventListener("alpine:init", () => {
    Alpine.data("theme", () => ({
        darkMode: false,
        init() {
            // Check if user has a saved preference
            const savedTheme = localStorage.getItem('darkMode');
            if (savedTheme) {
                this.darkMode = savedTheme === 'true';
                this.applyTheme();
            } else {
                // Check for system preference
                if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
                    this.darkMode = true;
                    this.applyTheme();
                }
            }
        },
        toggleDarkMode() {
            this.darkMode = !this.darkMode;
            localStorage.setItem('darkMode', this.darkMode);
            this.applyTheme();
        },
        applyTheme() {
            if (this.darkMode) {
                document.body.classList.add('dark-mode');
                document.documentElement.classList.add('dark');
            } else {
                document.body.classList.remove('dark-mode');
                document.documentElement.classList.remove('dark');
            }
        }
    }));
});

// Countries data handling and functionality
document.addEventListener("alpine:init", () => {
    Alpine.data("countries", () => ({
        countries: [],
        filteredCountries: [],
        selectedRegion: "",
        searchTerm: "",
        isLoading: true,
        selectedCountry: null,
        borderCountries: [],

        async init() {
            try {
                const response = await fetch("https://restcountries.com/v3.1/all");
                if (response.ok) {
                    this.countries = await response.json();
                    this.filteredCountries = [...this.countries];

                    // Check if there's a country in the URL
                    const urlParams = new URLSearchParams(window.location.search);
                    const countryParam = urlParams.get('country');

                    if (countryParam) {
                        this.showCountryDetails(countryParam);
                    }
                } else {
                    console.error("Failed to fetch countries");
                    // Fallback to local data if API fails
                    this.loadLocalData();
                }
            } catch (error) {
                console.error("Error fetching countries:", error);
                // Fallback to local data if API fails
                this.loadLocalData();
            } finally {
                this.isLoading = false;
            }
        },

        async loadLocalData() {
            try {
                const response = await fetch("data.json");
                this.countries = await response.json();
                this.filteredCountries = [...this.countries];
            } catch (error) {
                console.error("Error loading local data:", error);
            }
        },

        filterByRegion(region) {
            this.selectedRegion = region;
            this.applyFilters();
        },

        search() {
            this.applyFilters();
        },

        applyFilters() {
            this.filteredCountries = this.countries.filter(country => {
                const matchesSearch = this.searchTerm === "" ||
                    country.name.common.toLowerCase().includes(this.searchTerm.toLowerCase());

                const matchesRegion = this.selectedRegion === "" ||
                    country.region === this.selectedRegion;

                return matchesSearch && matchesRegion;
            });
        },

        async showCountryDetails(countryCode) {
            try {
                // If countryCode is a name, find by name, otherwise find by code
                const isCode = countryCode.length <= 3;

                let country;
                if (isCode) {
                    country = this.countries.find(c => c.cca3 === countryCode);
                } else {
                    country = this.countries.find(c =>
                        c.name.common.toLowerCase() === countryCode.toLowerCase());
                }

                if (!country) {
                    console.error("Country not found");
                    return;
                }

                this.selectedCountry = country;

                // Update URL
                const url = new URL(window.location);
                url.searchParams.set('country', isCode ? country.cca3 : country.name.common);
                window.history.pushState({}, '', url);

                // Get border countries
                this.borderCountries = [];
                if (country.borders && country.borders.length > 0) {
                    this.borderCountries = country.borders.map(borderCode => {
                        const borderCountry = this.countries.find(c => c.cca3 === borderCode);
                        return borderCountry ? {
                            name: borderCountry.name.common,
                            code: borderCode
                        } : null;
                    }).filter(c => c !== null);
                }

                // Show the detail view
                document.getElementById('countryList').classList.add('hidden');
                document.getElementById('countryDetail').classList.remove('hidden');

                // Scroll to top
                window.scrollTo(0, 0);
            } catch (error) {
                console.error("Error showing country details:", error);
            }
        },

        backToList() {
            this.selectedCountry = null;
            this.borderCountries = [];

            // Update URL
            const url = new URL(window.location);
            url.searchParams.delete('country');
            window.history.pushState({}, '', url);

            // Show the list view
            document.getElementById('countryList').classList.remove('hidden');
            document.getElementById('countryDetail').classList.add('hidden');
        },

        getLanguages(languages) {
            return languages ? Object.values(languages).join(', ') : 'N/A';
        },

        getCurrencies(currencies) {
            return currencies ? Object.values(currencies)
                .map(currency => currency.name)
                .join(', ') : 'N/A';
        },

        getNativeName(nativeName) {
            if (!nativeName) return 'N/A';
            // Get the first native name
            const firstKey = Object.keys(nativeName)[0];
            return nativeName[firstKey]?.common || 'N/A';
        }
    }));
});

// Format numbers with commas
function formatNumber(number) {
    return new Intl.NumberFormat().format(number);
}