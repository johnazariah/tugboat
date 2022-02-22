using GeneratedProjectName.Contract;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Threading.Tasks;

namespace GeneratedProjectName.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Produces("application/json")]
    public class CalculatorController : ControllerBase
    {
        private readonly Calculator calculator = new();

        public CalculatorController(ILogger<CalculatorController> logger)
        {
            Logger = logger;
        }

        public ILogger Logger { get; }

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
        [ProducesResponseType(typeof(int), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [HttpGet("{l}+{r}", Name = "Add")]
        public virtual async Task<IActionResult> Add(int l, int r)
        {
            var result = await calculator.Add(l, r);
            return Ok(result);
        }
    }
}
