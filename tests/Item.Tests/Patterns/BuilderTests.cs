using Microsoft.TemplateEngine.Authoring.TemplateVerifier;
using Microsoft.Extensions.Logging.Abstractions;
using System.Runtime.CompilerServices;

namespace Item.Tests.Patterns;

/// <summary>
/// Contains tests for the builder template, verifying that it generates the expected code based on default and custom arguments.
/// </summary>
public class BuilderTests
{
    private const string TemplateShortName = "eaton-ajk-patterns-builder";
    private static readonly string TemplatePath = ResolveTemplatePath();
    private static readonly string RunOutputRoot = CreateRunOutputRoot();

    [Test]
    public async Task BuilderTemplate_DefaultInstantiationTest()
    {
        string testOutputDir = CreateAndPrepareTestOutputDirectory();
        TemplateVerifierOptions options = new(templateName: TemplateShortName)
        {
            TemplatePath = TemplatePath,
            ScenarioName = "default-values",
            DoNotAppendTemplateArgsToScenarioName = true,
            //VerifyCommandOutput = true,
            DisableDiffTool = true,
            OutputDirectory = testOutputDir,
            SnapshotsDirectory = Path.Combine(testOutputDir, "Snapshots")
        };

        VerificationEngine engine = new(NullLogger.Instance);
        await engine.Execute(options).ConfigureAwait(false);
    }

    [Test]
    public async Task BuilderTemplate_CustomArgsInstantiationTest()
    {
        string testOutputDir = CreateAndPrepareTestOutputDirectory();
        TemplateVerifierOptions options = new(templateName: TemplateShortName)
        {
            TemplatePath = TemplatePath,
            ScenarioName = "custom-namespace-class-prefix",
            DoNotAppendTemplateArgsToScenarioName = true,
            //VerifyCommandOutput = true,
            OutputDirectory = testOutputDir,
            DisableDiffTool = true,
            SnapshotsDirectory = Path.Combine(testOutputDir, "Snapshots"),
            TemplateSpecificArgs =
            [
                "--name", "Order",
                "--Namespace", "My.App.Models",
                "--ClassName", "Order",
                "--BuilderPrefix", "Set"
            ]
        };

        VerificationEngine engine = new(NullLogger.Instance);
        await engine.Execute(options).ConfigureAwait(false);
    }

    /// <summary>
    /// Creates a unique output root under local_testing for the current test run.
    /// </summary>
    /// <returns>The absolute path to the run-specific output root.</returns>
    private static string CreateRunOutputRoot()
    {
        string runFolderName = $"template-verifier-{DateTime.UtcNow:yyyyMMdd-HHmmssfff}-{Guid.NewGuid():N}";
        string runPath = Path.Combine(ResolveLocalTestingPath(), runFolderName);
        Directory.CreateDirectory(runPath);

        return runPath;
    }

    /// <summary>
    /// Creates an isolated directory for each test and ensures it is empty before use.
    /// </summary>
    /// <param name="testName">The calling test name, captured automatically.</param>
    /// <returns>The path to the prepared test output directory.</returns>
    private static string CreateAndPrepareTestOutputDirectory([CallerMemberName] string? testName = null)
    {
        string safeTestName = string.IsNullOrWhiteSpace(testName) ? "unknown-test" : testName;
        string testOutputPath = Path.Combine(RunOutputRoot, safeTestName);

         if (Directory.Exists(testOutputPath))
         {
             Directory.Delete(testOutputPath, recursive: true);
         }

         Directory.CreateDirectory(testOutputPath);
         return testOutputPath;
    }

    /// <summary>
    /// Resolves the path to the builder template directory by traversing up the directory tree from the base directory of the
    /// application context until it finds the solution file "Eaton.AustinKaylor.Templates.slnx".
    /// </summary>
    /// <remarks>
    /// Once found, it constructs and returns the path to the "templates/item/patterns/builder" directory. <br/>
    /// If the solution file is not found, an InvalidOperationException is thrown.
    /// </remarks>
    /// <returns>The path to the builder template directory.</returns>
    /// <exception cref="InvalidOperationException">Thrown if the solution file is not found.</exception>
    private static string ResolveTemplatePath()
    {
        DirectoryInfo? current = new(AppContext.BaseDirectory);

        while (current is not null)
        {
            if (File.Exists(Path.Combine(current.FullName, "Eaton.AustinKaylor.Templates.slnx")))
            {
                return Path.Combine(current.FullName, "templates", "item", "patterns", "builder");
            }

            current = current.Parent;
        }

        throw new InvalidOperationException("Could not locate repository root for builder template tests.");
    }

    /// <summary>
    /// Resolves the path to the local testing directory by traversing up the directory tree from the base directory of the
    /// application context until it finds the solution file "Eaton.AustinKaylor.Templates.slnx". <br/>
    /// Once found, it constructs and returns the path to the "tests/Item.Tests/Patterns" directory. <br/>
    /// If the solution file is not found, an InvalidOperationException is thrown.
    /// </summary>
    /// <returns>The path to the local testing directory.</returns>
    /// <exception cref="InvalidOperationException">Thrown if the solution file is not found.</exception>
    private static string ResolveLocalTestingPath()
    {
        DirectoryInfo? current = new(AppContext.BaseDirectory);

        while (current is not null)
        {
            if (File.Exists(Path.Combine(current.FullName, "Eaton.AustinKaylor.Templates.slnx")))
            {
                return Path.Combine(current.FullName, "local_testing");
            }

            current = current.Parent;
        }

        throw new InvalidOperationException("Could not locate repository root for local_testing.");
    }
}