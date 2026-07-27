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
    private const string CustomNamespace = "My.App.Models";
    private const string CustomClassName = "Order";
    private static readonly string TemplatePath = ResolveTemplatePath();
    private static readonly string RunOutputRoot = CreateRunOutputRoot();
    private static readonly string BaselineSnapshotsRoot = ResolveBaselineSnapshotsPath();

    /// <summary>
    /// Tests the Builder Pattern Item Template with the following values: <br/>
    /// <c>Namespace</c>: default <br/>
    /// <c>ClassName</c>: default <br/>
    /// <c>BuilderPrefix</c>: With
    /// </summary>
    [Test]
    public async Task BuilderTemplate_DefaultInstantiationTest()
    {
        TemplateVerifierOptions options = CreateScenarioOptions("default-values", nameof(BuilderTemplate_DefaultInstantiationTest));
        VerificationEngine engine = new(NullLogger.Instance);
        await engine.Execute(options).ConfigureAwait(false);
    }

    /// <summary>
    /// Tests the Builder Pattern Item Template with custom namespace, class name, and builder prefix arguments. <br/>
    /// <c>Namespace</c>: My.App.Models <br/>
    /// <c>ClassName</c>: Order <br/>
    /// <c>BuilderPrefix</c>: Set
    /// </summary>
    [Test]
    public async Task BuilderTemplate_CustomArgsInstantiationTest()
    {
        TemplateVerifierOptions options = CreateScenarioOptions(
            "custom-namespace-class-prefix",
            nameof(BuilderTemplate_CustomArgsInstantiationTest),
            "--Namespace", CustomNamespace,
            "--ClassName", CustomClassName,
            "--BuilderPrefix", "Set");
        VerificationEngine engine = new(NullLogger.Instance);
        await engine.Execute(options).ConfigureAwait(false);
    }

    /// <summary>
    /// Tests the Builder Pattern Item Template with default namespace and class name, but a custom builder prefix argument. <br/>
    /// <c>Namespace</c>: default <br/>
    /// <c>ClassName</c>: default <br/>
    /// <c>BuilderPrefix</c>: Set
    /// </summary>
    [Test]
    public async Task BuilderTemplate_DefaultNamespaceDefaultClassSetPrefixInstantiationTest()
    {
        TemplateVerifierOptions options = CreateScenarioOptions(
            "default-namespace-default-class-set-prefix",
            nameof(BuilderTemplate_DefaultNamespaceDefaultClassSetPrefixInstantiationTest),
            "--BuilderPrefix", "Set");
        VerificationEngine engine = new(NullLogger.Instance);
        await engine.Execute(options).ConfigureAwait(false);
    }

    /// <summary>
    /// Tests the Builder Pattern Item Template with default namespace and class name, but a custom builder prefix argument. <br/>
    /// <c>Namespace</c>: default <br/>
    /// <c>ClassName</c>: Order <br/>
    /// <c>BuilderPrefix</c>: Set
    /// </summary>
    [Test]
    public async Task BuilderTemplate_DefaultNamespaceCustomClassWithPrefixInstantiationTest()
    {
        TemplateVerifierOptions options = CreateScenarioOptions(
            "default-namespace-custom-class-with-prefix",
            nameof(BuilderTemplate_DefaultNamespaceCustomClassWithPrefixInstantiationTest),
            "--ClassName", CustomClassName);
        VerificationEngine engine = new(NullLogger.Instance);
        await engine.Execute(options).ConfigureAwait(false);
    }

    /// <summary>
    /// Tests the Builder Pattern Item Template with default namespace and class name, but a custom builder prefix argument. <br/>
    /// <c>Namespace</c>: default <br/>
    /// <c>ClassName</c>: Order <br/>
    /// <c>BuilderPrefix</c>: Set
    /// </summary>
    [Test]
    public async Task BuilderTemplate_DefaultNamespaceCustomClassSetPrefixInstantiationTest()
    {
        TemplateVerifierOptions options = CreateScenarioOptions(
            "default-namespace-custom-class-set-prefix",
            nameof(BuilderTemplate_DefaultNamespaceCustomClassSetPrefixInstantiationTest),
            "--ClassName", CustomClassName,
            "--BuilderPrefix", "Set");
        VerificationEngine engine = new(NullLogger.Instance);
        await engine.Execute(options).ConfigureAwait(false);
    }

    /// <summary>
    /// Tests the Builder Pattern Item Template with default namespace and class name, but a custom builder prefix argument. <br/>
    /// <c>Namespace</c>: default <br/>
    /// <c>ClassName</c>: default <br/>
    /// <c>BuilderPrefix</c>: Set
    /// </summary>
    [Test]
    public async Task BuilderTemplate_CustomNamespaceDefaultClassWithPrefixInstantiationTest()
    {
        TemplateVerifierOptions options = CreateScenarioOptions(
            "custom-namespace-default-class-with-prefix",
            nameof(BuilderTemplate_CustomNamespaceDefaultClassWithPrefixInstantiationTest),
            "--Namespace", CustomNamespace);
        VerificationEngine engine = new(NullLogger.Instance);
        await engine.Execute(options).ConfigureAwait(false);
    }

    /// <summary>
    /// Tests the Builder Pattern Item Template with default namespace and class name, but a custom builder prefix argument. <br/>
    /// <c>Namespace</c>: My.App.Models <br/>
    /// <c>ClassName</c>: default <br/>
    /// <c>BuilderPrefix</c>: Set
    /// </summary>
    [Test]
    public async Task BuilderTemplate_CustomNamespaceDefaultClassSetPrefixInstantiationTest()
    {
        TemplateVerifierOptions options = CreateScenarioOptions(
            "custom-namespace-default-class-set-prefix",
            nameof(BuilderTemplate_CustomNamespaceDefaultClassSetPrefixInstantiationTest),
            "--Namespace", CustomNamespace,
            "--BuilderPrefix", "Set");
        VerificationEngine engine = new(NullLogger.Instance);
        await engine.Execute(options).ConfigureAwait(false);
    }

    /// <summary>
    /// Tests the Builder Pattern Item Template with default namespace and class name, but a custom builder prefix argument. <br/>
    /// <c>Namespace</c>: My.App.Models <br/>
    /// <c>ClassName</c>: Order <br/>
    /// <c>BuilderPrefix</c>: With
    /// </summary>
    [Test]
    public async Task BuilderTemplate_CustomNamespaceCustomClassWithPrefixInstantiationTest()
    {
        TemplateVerifierOptions options = CreateScenarioOptions(
            "custom-namespace-custom-class-with-prefix",
            nameof(BuilderTemplate_CustomNamespaceCustomClassWithPrefixInstantiationTest),
            "--Namespace", CustomNamespace,
            "--ClassName", CustomClassName);
        VerificationEngine engine = new(NullLogger.Instance);
        await engine.Execute(options).ConfigureAwait(false);
    }

    /// <summary>
    /// Creates template verifier options for a single named scenario.
    /// </summary>
    /// <param name="scenarioName">The stable scenario name used by snapshot verification.</param>
    /// <param name="testName">The test method name used for output directory isolation.</param>
    /// <param name="templateSpecificArgs">Template symbol arguments to pass to the template engine.</param>
    /// <returns>Template verifier options configured for the current scenario.</returns>
    private static TemplateVerifierOptions CreateScenarioOptions(
        string scenarioName,
        string testName,
        params string[] templateSpecificArgs)
    {
        string testOutputDir = CreateAndPrepareTestOutputDirectory(testName);
        string snapshotsDirectory = PrepareSnapshotsDirectory();

        return new TemplateVerifierOptions(templateName: TemplateShortName)
        {
            TemplatePath = TemplatePath,
            ScenarioName = scenarioName,
            DoNotAppendTemplateArgsToScenarioName = true,
            //VerifyCommandOutput = true,
            DisableDiffTool = true,
            OutputDirectory = testOutputDir,
            SnapshotsDirectory = snapshotsDirectory,
            TemplateSpecificArgs = templateSpecificArgs
        };
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
    /// Copies baseline snapshots into a test-specific snapshot directory so verification is deterministic.
    /// </summary>
    /// <returns>The path to the prepared snapshots directory.</returns>
    private static string PrepareSnapshotsDirectory()
    {
        string snapshotsPath = Path.Combine(RunOutputRoot, "snapshot-baseline", Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(snapshotsPath);

        CopyDirectory(BaselineSnapshotsRoot, snapshotsPath);
        return snapshotsPath;
    }

    /// <summary>
    /// Recursively copies one directory tree into another.
    /// </summary>
    /// <param name="sourceDirectoryPath">The directory to copy from.</param>
    /// <param name="destinationDirectoryPath">The directory to copy into.</param>
    private static void CopyDirectory(string sourceDirectoryPath, string destinationDirectoryPath)
    {
        Directory.CreateDirectory(destinationDirectoryPath);

        foreach (string filePath in Directory.GetFiles(sourceDirectoryPath))
        {
            string fileName = Path.GetFileName(filePath);
            string destinationPath = Path.Combine(destinationDirectoryPath, fileName);
            File.Copy(filePath, destinationPath, overwrite: true);
        }

        foreach (string directoryPath in Directory.GetDirectories(sourceDirectoryPath))
        {
            string directoryName = Path.GetFileName(directoryPath);
            string destinationPath = Path.Combine(destinationDirectoryPath, directoryName);
            CopyDirectory(directoryPath, destinationPath);
        }
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

    /// <summary>
    /// Resolves the path to the checked-in snapshot baseline directory.
    /// </summary>
    /// <returns>The path to the snapshot baseline directory.</returns>
    /// <exception cref="InvalidOperationException">Thrown if the repository root or snapshots directory is not found.</exception>
    private static string ResolveBaselineSnapshotsPath()
    {
        DirectoryInfo? current = new(AppContext.BaseDirectory);

        while (current is not null)
        {
            if (File.Exists(Path.Combine(current.FullName, "Eaton.AustinKaylor.Templates.slnx")))
            {
                string snapshotsPath = Path.Combine(current.FullName, "tests", "Item.Tests", "Patterns", "Snapshots");
                if (!Directory.Exists(snapshotsPath))
                {
                    throw new InvalidOperationException("Could not locate checked-in snapshots for builder template tests.");
                }

                return snapshotsPath;
            }

            current = current.Parent;
        }

        throw new InvalidOperationException("Could not locate repository root for builder template test snapshots.");
    }
}