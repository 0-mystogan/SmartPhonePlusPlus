using Microsoft.AspNetCore.Mvc;
using SmartPhone.Services.Interfaces;
using SmartPhone.WebAPI.Reports;
using System;
using System.Threading.Tasks;

namespace SmartPhone.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ServiceVerificationController : ControllerBase
    {
        private readonly IServiceService _serviceService;
        private readonly IServiceVerificationReportService _reportService;

        public ServiceVerificationController(IServiceService serviceService, IServiceVerificationReportService reportService)
        {
            _serviceService = serviceService;
            _reportService = reportService;
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> Get(int id)
        {
            try
            {
                var verification = await _serviceService.GetVerificationAsync(id);
                if (verification == null)
                    return NotFound();

                var pdfBytes = _reportService.Generate(verification);
                var fileName = $"ServiceVerification_{verification.ServiceId:0000}.pdf";
                return File(pdfBytes, "application/pdf", fileName);
            }
            catch (Exception ex)
            {
                if (ex.Message == "Service not found")
                    return NotFound();
                throw;
            }
        }
    }
}


