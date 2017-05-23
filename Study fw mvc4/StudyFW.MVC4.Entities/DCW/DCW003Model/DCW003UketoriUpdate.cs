using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StudyFW.MVC4.Entities.DCW.DCW003Model
{
	public class DCW003UketoriUpdate
	{
		public string DocControlNo { get; set; }

        public string JishameiFlag { get; set; }
		//START_20160118_ADD_TRAMD

        //public string FuzokuhinCd { get; set; }

        //public DateTime? HakkoDate { get; set; }
		//END_20160118_ADD_TRAMD

		public DateTime? ShakenLimitDate { get; set; }

		public DateTime? ShoruiLimitDate { get; set; }

		public DateTime? MeihenShakenTorokuDate { get; set; }
	}
}
