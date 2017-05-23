using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StudyFW.MVC4.Entities.DCW.DCW003Model
{
   public class DCW003ListReturnUpdate
    {

        /// <summary>
        /// 出品店情報
        /// </summary>
        public string ShopName { get; set; }
        /// <summary>
        /// 落札店情報
        /// </summary>
        public string RakusatsuShopName { get; set; }
        /// <summary>
        /// DN成約日
        /// </summary>
        public DateTime? DnSeiyakuDate { get; set; }
        public string   DnSeiyakuDateValue { get; set; }

        /// <summary>
        /// 仕入番号
        /// </summary>
        public string ShiireNo { get; set; }
    }
}
