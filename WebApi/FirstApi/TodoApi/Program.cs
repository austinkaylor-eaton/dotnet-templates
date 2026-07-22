using Microsoft.EntityFrameworkCore;

using Scalar.AspNetCore;

using TodoApi;
using TodoApi.OpenAPI;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();

// Adds problem details default implementation -> https://learn.microsoft.com/en-us/aspnet/core/fundamentals/error-handling-api?view=aspnetcore-10.0&tabs=controllers#problem-details-service
builder.Services.AddProblemDetails(options =>
{
    options.CustomizeProblemDetails = new ProblemDetailsCustomizer().Customize;
});

// Register a custom exception handler
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();

// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi(options =>
{
    options.AddDocumentTransformer<ApiSummaryDocumentTransformer>();
    options.AddOperationTransformer<InternalServerErrorOperationTransformer>();
    options.AddOperationTransformer<ResponseExamplesOperationTransformer>();
    options.AddSchemaTransformer<CustomSchemaTransformer>();
});
builder.Services.AddDbContext<TodoContext>(opt =>
    opt.UseInMemoryDatabase("TodoList"));

var app = builder.Build();

// Converts unhandled exceptions into Problem Details responses
app.UseExceptionHandler();

// Returns the Problem Details response for (empty) non-successful responses
app.UseStatusCodePages();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    // configure the swagger middleware -> https://learn.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-10.0&tabs=visual-studio-code#configure-swagger-middleware
    app.UseSwaggerUi(options =>
    {
        options.DocumentPath = "/openapi/v1.json";
    });
    // configure scalar -> https://learn.microsoft.com/en-us/aspnet/core/fundamentals/openapi/using-openapi-documents?view=aspnetcore-10.0#use-scalar-for-interactive-api-documentation
    app.MapScalarApiReference();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
