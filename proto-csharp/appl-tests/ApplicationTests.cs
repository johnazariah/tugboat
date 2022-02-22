using FsCheck.Xunit;
using GeneratedProjectName.Contract;
using System.Threading.Tasks;
using Xunit;

namespace Test.GeneratedProjectName
{
    public class ApplicationTests
    {
        private readonly Calculator _calculator = new();
        /// <summary>
        /// This is a traditional unit test.
        ///
        /// Provide known inputs and check the actual result against a known expected value
        /// </summary>
        /// <returns></returns>
        [Fact]
        public async Task KnownNumbersAreAddedCorrectly()
        {
            var result = await _calculator.Add(1, 2);
            Assert.Equal(3, result);
        }

        /// <summary>
        /// This is a property-based test.
        ///
        /// The test-runner will generate a large number of random values for
        /// <paramref name="l"/> and <paramref name="r"/> each time the test is run,
        /// and we will test a **property** of the addition operation.
        ///
        /// Mathematically, addition is the *only* operation to be
        ///     * associative
        ///     * commutative
        ///     * have an identity of zero
        /// so checking these three properties proves the addition operation is correct.
        ///
        /// In this test, we check that zero is the additive identity.
        ///
        /// </summary>
        /// <param name="l"></param>
        /// <param name="r"></param>
        /// <returns>`true` if the test should pass, `false` otherwise</returns>
        [Property]
        public bool AdditionIdentityIsZero(int x)
        {
            async Task<bool> identityCheck()
            {
                var forwardSum = await _calculator.Add(0, x);
                var reverseSum = await _calculator.Add(x, 0);
                return (x == forwardSum) && (x == reverseSum);
            }

            return identityCheck().Result;
        }

        /// <summary>
        /// This is a property-based test.
        ///
        /// The test-runner will generate a large number of random values for
        /// <paramref name="l"/> and <paramref name="r"/> each time the test is run,
        /// and we will test a **property** of the addition operation.
        ///
        /// Mathematically, addition is the *only* operation to be
        ///     * associative
        ///     * commutative
        ///     * have an identity of zero
        /// so checking these three properties proves the addition operation is correct.
        ///
        /// In this test, we check that the property of commutativity is satisfied
        ///
        /// </summary>
        /// <param name="l"></param>
        /// <param name="r"></param>
        /// <returns>`true` if the test should pass, `false` otherwise</returns>
        [Property]
        public bool AdditionIsCommutative(int l, int r)
        {
            async Task<bool> commutativityCheck()
            {
                var forwardSum = await _calculator.Add(l, r);
                var reverseSum = await _calculator.Add(r, l);
                return forwardSum == reverseSum;
            }

            return commutativityCheck().Result;
        }

        /// <summary>
        /// This is a property-based test.
        ///
        /// The test-runner will generate a large number of random values for
        /// <paramref name="l"/> and <paramref name="r"/> each time the test is run,
        /// and we will test a **property** of the addition operation.
        ///
        /// Mathematically, addition is the *only* operation to be
        ///     * associative
        ///     * commutative
        ///     * have an identity of zero
        /// so checking these three properties proves the addition operation is correct.
        ///
        /// In this test, we check that the property of associativity is satisfied
        ///
        /// </summary>
        /// <param name="l"></param>
        /// <param name="r"></param>
        /// <returns>`true` if the test should pass, `false` otherwise</returns>
        [Property]
        public bool AdditionIsAssociative(int x1, int x2, int x3)
        {
            async Task<bool> associativityCheck()
            {
                var forwardSum = await _calculator.Add(x1, await _calculator.Add(x2, x3));
                var reverseSum = await _calculator.Add(await _calculator.Add(x1, x2), x3);
                return forwardSum == reverseSum;
            }

            return associativityCheck().Result;
        }
    }
}
