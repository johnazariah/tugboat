namespace GeneratedProjectName.Controllers
open Microsoft.AspNetCore.Http
open Microsoft.AspNetCore.Mvc
open Microsoft.Extensions.Logging
open System.Threading.Tasks
open GeneratedProjectName.Contract

[<ApiController>]
[<Route("api/[controller]")>]
[<Produces("application/json")>]
type public CalculatorController (logger) = class
    inherit ControllerBase()
    member val Logger : ILogger = logger

    /// <summary>
    /// Adds two numbers provided
    /// </summary>
    /// <param name="l">An integer to add</param>
    /// <param name="r">An integer to add</param>
    /// <remarks>
    /// Sample request:
    ///
    ///     GET /api/Adder/4+5
    ///
    /// </remarks>
    /// <returns>The sum of the two numbers provided.</returns>
    [<ProducesResponseType(typeof<int>, StatusCodes.Status200OK)>]
    [<ProducesResponseType(StatusCodes.Status400BadRequest)>]
    [<HttpGet("{l}+{r}", Name = "Add")>]
    abstract Add : int -> int -> Task<int>
    default _.Add l r =
        Calculator.Add l r
end