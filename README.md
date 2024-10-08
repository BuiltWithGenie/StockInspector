## Stock inspector dashboard

A dashboard to inspect stocks with data from Yahoo Finance. See the video tutorial [here](https://www.youtube.com/watch?v=4ypKzNagGXk) and check out the [app gallery](https://learn.genieframework.com/app-gallery) for more Genie app examples.

## Installation

Clone the repository and install the dependencies:

First `cd` into the project directory then run:

```bash
$> julia --project -e 'using Pkg; Pkg.instantiate()'
```

Then run the app

```bash
$> julia --project
```

```julia
julia> using GenieFramework
julia> Genie.loadapp() # load app
julia> up() # start server
```

## Usage

Open your browser and navigate to `http://localhost:8000/`
