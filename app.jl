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

using Dates

function time_elapsed(num_days::Int)
    current_time = now()
    past_time = current_time - Day(num_days)

    delta_days = Dates.value(Dates.Day(current_time - past_time))
    years, remaining_days = divrem(delta_days, 365)
    months, days = divrem(remaining_days, 30)

    elapsed_time = String[]
    if years > 0
        push!(elapsed_time, "$(years) year$(years > 1 ? "s" : "")")
    end
    if months > 0
        push!(elapsed_time, "$(months) month$(months > 1 ? "s" : "")")
    end
    if days > 0
        push!(elapsed_time, "$(days) day$(days > 1 ? "s" : "")")
    end

    return join(elapsed_time, ", ")
end

@app begin
    @in start_date = "2021-01-01"
    @in end_date = "2022-01-01"
    @out elapsed = "1 year"
    @out stocks = symbols
    @in selected_stock = "AAPL"
    @in prices = DataFrame(ticker=[], close=[], timestamp=[], ma20=[])
    @out endval = 0.0
    @out period_diff = 0.0
    @out percent_return = 0.0
    @out avgval = 0.0
    @out news = [Dict()]
    @in window = 365
    @onchange isready, start_date, end_date, selected_stock begin
        try
        prices = get_symbol_prices([selected_stock], start_date, end_date) |> add_ma20!
    catch e
        @show e
    end
        @show prices.close
        endval = round(prices[!,:close][end], digits=3)
        period_diff = round(prices[!,:close][end] - prices[!,:close][1], digits=3)
        percent_return = round((prices[!,:close][end] - prices[!,:close][1]) / prices[!,:close][1] * 100, digits=3)
        avgval = round(mean(prices[!,:close]), digits=3)
        elapsed = time_elapsed(Dates.value(Dates.Day(Date(end_date)-Date(start_date))))
        @show elapsed, Dates.value(Dates.Day(Date(end_date)-Date(start_date)))
    end
    @onchange isready, selected_stock begin
        news = get_news([selected_stock])[1] |> convert_to_serializable
    end
    @onchange window begin
        start_date[!] = today() - Day(window) |> string # update variable without triggering the handler
        @push start_date
        end_date = today() |> string
        elapsed = time_elapsed(window)
    end
end

@page("/", "app.jl.html")
end



