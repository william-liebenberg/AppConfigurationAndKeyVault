using AppService.AppInsights.Monitoring;
using Azure.Identity;
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

// authenticate using default (managed identity) credentials for AppInsights
builder.Services.Configure<TelemetryConfiguration>(config =>
{
    var credential = new DefaultAzureCredential();
    config.SetAzureTokenCredential(credential);
});

// When using User Secrets for local development:
//  Strange behaviour from the Initializers when using the parameterless version of .AddApplicationInsightsTelemetry()
//  They end up not receiving the ApplicationInsights:ConnectionString specified in secrets.json
//  By passing in the builder.Configuration ensures the Initializers and TelemetryClients are configured properly
builder.Services.AddApplicationInsightsTelemetry(builder.Configuration);
builder.Services.AddSingleton<ITelemetryInitializer, UserAgentTelemetryInitializer>();

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.

// Mutate the usual 404 NOT FOUND into 204 OK when the front-end load balancer hits the root of the site every 5 minutes (for Always On setting)
// See why "AlwaysOn" generates this traffic: https://learn.microsoft.com/en-us/azure/app-service/configure-common?tabs=portal#configure-general-settings
app.UseAlwaysOnHandlerMiddleware();

app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();

// simple endpoint to track request, event, and trace
app.MapGet("/test", ([FromServices]TelemetryClient tc) =>
{
    tc.TrackEvent("TEST EVENT");
    tc.TrackTrace("Hi! Ignore me, I'm just testing stuff !!!");

    return "You got to the /test endpoint - somehow!";
})
.WithName("GetTest")
.WithOpenApi();

app.Run();
