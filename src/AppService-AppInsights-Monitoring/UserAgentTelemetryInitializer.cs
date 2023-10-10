using Microsoft.ApplicationInsights.Channel;
using Microsoft.ApplicationInsights.DataContracts;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.Net.Http.Headers;

namespace AppService.AppInsights.Monitoring;

public class UserAgentTelemetryInitializer : ITelemetryInitializer
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public UserAgentTelemetryInitializer(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public void Initialize(ITelemetry telemetry)
    {
        if (_httpContextAccessor.HttpContext is not null && telemetry is RequestTelemetry requestTelemetry)
        {
            if (_httpContextAccessor.HttpContext.Request.Headers.TryGetValue(HeaderNames.UserAgent, out var userAgent))
            {
                requestTelemetry.Properties.Add(HeaderNames.UserAgent, userAgent);
            }
        }
    }
}