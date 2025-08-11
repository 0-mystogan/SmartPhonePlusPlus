using SmartPhone.Model.Responses;

namespace SmartPhone.WebAPI.Reports
{
    public interface IServiceVerificationReportService
    {
        byte[] Generate(ServiceVerificationResponse verification);
    }
}


