﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StudyFW.MVC4.Entities.DCW.DCW003Model
{
	public class DCW003UketoriDetail
	{
		public string DocControlNo { get; set; }

		public string DocFuzoKuhinCd { get; set; }

        public string DefaulCheckType { get; set; }

        public string HisUketoriDocControlNo { get; set; }

		public int DocCount { get; set; }

		public string Note { get; set; }

		public int IsChecked { get; set; }
	}
}
