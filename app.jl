module App
# set up Genie development environment
using GenieFramework, Dates, DataFrames
include("stock-analysis.jl")
@genietools
symbols = [
    "AAPL", "TSLA", "MSFT", "A", "AAL", "AAP", "ABBV", "ABC", "ABMD", "ABT",
    "ACN", "ADBE", "ADI", "ADM", "ADP", "ADSK", "AEE", "AEP", "AES", "AFL",
    "AIG", "AIZ", "AJG", "AKAM", "ALB", "ALGN", "ALK", "ALL", "ALLE", "ALXN",
    "AMAT", "AMCR", "AMD", "AME", "AMGN", "AMP", "AMT", "AMZN", "ANET", "ANSS",
    "ANTM", "AON", "AOS", "APA", "APD", "APH", "APTV", "ARE", "ATO", "ATVI",
    "AVB", "AVGO", "AVY", "AWK", "AXP", "AZO", "BA", "BAC", "BAX", "BBY",
    "BDX", "BEN", "BF.B", "BIIB", "BIO", "BK", "BKNG", "BKR", "BLK", "BLL",
    "BMY", "BR", "BRK.B", "BSX", "BWA", "BXP", "C", "CAG", "CAH", "CARR",
    "CAT", "CB", "CBOE", "CBRE", "CCI", "CCL", "CDNS", "CDW", "CE", "CERN",
    "CF", "CFG", "CHD", "CHRW", "CHTR", "CI", "CINF", "CL", "CLX", "CMA"
]

# add reactive code to make the UI interactive
@app begin
    @in start_date = "2021-01-01"
    @in end_date = "2022-01-01"
    @out stocks = symbols
    @in selected_stock = "AAPL"
    @out prices = DataFrame(ticker=[], close=[], timestamp=[], ma20=[])
    @out endval = 0.0
    @out period_diff = 0.0
    @out percent_return = 0.0
    @out avgval = 0.0
    @out ma20 = [1.0,2.0]
    @out news = [Dict()]
    @in window = 365
    @onchange isready, start_date, end_date, selected_stock begin
        prices = get_symbol_prices([selected_stock], start_date, end_date)
        monthly = get_monthly_prices!(prices)
        endval = round(prices[!,:close][end], digits=3)
        period_diff = round(prices[!,:close][end] - prices[!,:close][1], digits=3)
        prices[!,:ma20] = moving_average(prices, :close,20)
        ma20 = prices[!,:ma20]
        percent_return = round((prices[!,:close][end] - prices[!,:close][1]) / prices[!,:close][1] * 100, digits=3)
        avgval = round(mean(prices[!,:close]), digits=3)
        news = get_news([selected_stock])[1] |> convert_to_serializable
    end
    @onchange window begin
        start_date[!] = today() - Day(window) |> string # update variable without triggering the handler
        @push start_date
        end_date = today() |> string
    end
end


# register a new route and the page that will be
# loaded on access
@page("/", "app.jl.html")
end



