public class SnowAttributes {
	
	public class SnowAttributesWrapper{
		public String displayFieldName;
		public FieldAliases fieldAliases;
		public List<Fields> fields;
		public List<Features> features;
		
		public SnowAttributesWrapper(String displayFieldName){
			this.displayFieldName=displayFieldName;
		}
	}
	
	public class FieldAliases {
		public String OBJECTID;
		public String PARTIAL_AREA;
		public String SNOWAREA;
		public String SNOWZONE;
		public String AREA;
		public String LEN;
		public String GIS_ID;
		public String SMD_ID;
		public String ANC_ID;		
		public String WARD;
		public String QUADRANT;		
		//POLDISTRICT NAME	
		public String POLDIST;
		public String CLUSTER;		
		public String PSA;
		public String ZIPCODE;		
		
	}
	
	public class Attributes {
		public Integer OBJECTID;
		public Integer PARTIAL_AREA;
		public Integer SNOWAREA;
		public Integer SNOWZONE;
		public Integer AREA;
		public Integer LEN;
		public String SMD_ID;
		public String ANC_ID;	
		public String WARD;
		public String QUADRANT;	
		//POLDISTRICT NAME	
		public String POLDIST;
		public String CLUSTER;		
		public String PSA;
		public String ZIPCODE;	
	}

	public class Fields {
		public String name;
		public String type;
		public String alias;
	}
	
	public class Features {
		public Attributes attributes;
	}
}