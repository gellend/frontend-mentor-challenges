// tailwind custom
tailwind.config = {
    theme: {
        extend: {
            colors: {
                "light-cyan": "hsl(193, 38%, 86%)",
                "neon-green": "hsl(150, 100%, 66%)",
                "grayish-blue": "hsl(217, 19%, 38%)",
                "dark-grayish-blue": "hsl(217, 19%, 24%)",
                "dark-blue": "hsl(218, 23%, 16%)",
            },
        },
    },
};

// fetch countries
document.addEventListener("alpine:init", () => {
    Alpine.data("countries", () => ({
        countries: [],
        async init() {
            this.countries = await (
                await fetch("https://restcountries.com/v3.1/all")
            ).json();
        },
    }));
});

// format number
function formatNumber(number) {
    return new Intl.NumberFormat().format(number);
}