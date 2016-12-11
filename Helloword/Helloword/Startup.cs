using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(Helloword.Startup))]
namespace Helloword
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
