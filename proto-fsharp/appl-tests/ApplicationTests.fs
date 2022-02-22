namespace Test.GeneratedProjectName

open FsCheck.Xunit
open Xunit
open GeneratedProjectName.Contract

type public ApplicationTests() = class
    /// <summary>
    /// This is a traditional unit test.
    ///
    /// Provide known inputs and check the actual result against a known expected value
    /// </summary>
    /// <returns></returns>
    [<Fact>]
    member _.KnownNumbersAreAddedCorrectly () =
        task {
            let! result = Calculator.Add 1 2
            do Assert.Equal(3, result)
        }
        |> Async.AwaitTask
        |> Async.RunSynchronously

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
    [<Property>]
    member _.AdditionIdentityIsZero (x : int) =
        task {
            let! ``0 plus x`` = Calculator.Add 0 x
            let! ``x plus 0`` = Calculator.Add x 0
            return (``0 plus x`` = ``x plus 0``) && (x = ``0 plus x``)
        }
        |> Async.AwaitTask
        |> Async.RunSynchronously

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
    [<Property>]
    member _.AdditionIsCommutative (l : int, r : int) =
        task {
            let! ``l plus r`` = Calculator.Add l r
            let! ``r plus l`` = Calculator.Add r l
            return ``l plus r`` = ``r plus l``
        }
        |> Async.AwaitTask
        |> Async.RunSynchronously

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
    [<Property>]
    member _.AdditionIsAssociative (x1 : int, x2 : int, x3 : int) =
        task {
            let! ``x2 plus x3`` = Calculator.Add x2 x3
            let! ``x1 plus (x2 plus x3)`` = Calculator.Add x1 ``x2 plus x3``

            let! ``x1 plus x2`` = Calculator.Add x1 x2
            let! ``(x1 plus x2) plus x3`` = Calculator.Add ``x1 plus x2`` x3

            return ``x1 plus (x2 plus x3)`` = ``(x1 plus x2) plus x3``
        }
        |> Async.AwaitTask
        |> Async.RunSynchronously
end