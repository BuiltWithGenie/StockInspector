module App
# set up Genie development environment
using GenieFramework, Dates, DataFrames
include("etf-analysis.jl")
@genietools

# add your data analysis code
function mean_value(x)
    sum(x) / length(x)
end


# add reactive code to make the UI interactive
@app begin
    # reactive variables are tagged with @in and @out
    @in N = 0
    @in start_date = "2023-01-01"
    @in end_date = "2024-01-01"
    @out msg = "The average is 0."
    @out tabdata = DataTable()
    @out symbols = ["AAPL","NFLX","TSLA"]
    @in selected_symbol = "AAPL"
    @out prices = DataFrame()
    @out prices_arr = [1.1,2]
    @out prices_ticks = [1,2]
    @out period_diff = 0.0
    @out news = ""
    @onchange selected_symbol, start_date, end_date begin
        prices = get_symbol_prices([selected_symbol], start_date, end_date)
        prices_arr = prices[!, :close]
        prices_ticks = collect(1:length(prices_arr))
        monthly = get_monthly_prices!(prices)
        period_diff = round(get_period_diff(monthly)[!,:total][1], digits=3)
        @show period_diff
        news = get_news([selected_symbol]) |> string
    end
end

# register a new route and the page that will be
# loaded on access
@page("/", "app.jl.html")
end
