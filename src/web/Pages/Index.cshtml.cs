using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Microsoft.Data.SqlClient;
using DemoFrontend.Models;

namespace DemoFrontend.Pages
{
    public class IndexModel : PageModel
    {
        private readonly ILogger<IndexModel> _logger;
        public List<Student> Students { get; set; }

        public IndexModel(ILogger<IndexModel> logger)
        {
            _logger = logger;
        }

        public void OnGet()
        {
            this.Students = GetStudentsFromDB();
        }

        private List<Student> GetStudentsFromDB()
        {
            var studentsList = new List<Student>();
            using (SqlConnection sqlConnection = new SqlConnection(GetKeyVaultSecret("SQLDBConnString").Value))
            {
                try
                {
                    sqlConnection.Open();
                    String sql = "SELECT StudentName, StudentGrade FROM dbo.Students";

                    using (SqlCommand command = new SqlCommand(sql, sqlConnection))
                    {
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                Student student = new Student()
                                {
                                    StudentName = reader.GetString(0),
                                    StudentGrade = reader.GetString(1)
                                };
                                studentsList.Add(student);
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex.Message);
                }
            }
            return studentsList;
        }

        private KeyVaultSecret GetKeyVaultSecret(string secret)
        {
            string keyVaultName = Environment.GetEnvironmentVariable("KEY_VAULT_NAME");
            var kvUri = "https://" + keyVaultName + ".vault.azure.net";

            var client = new SecretClient(new Uri(kvUri), new DefaultAzureCredential());
            KeyVaultSecret kvsecret = client.GetSecret(secret);
            return kvsecret;
        }
    }
}