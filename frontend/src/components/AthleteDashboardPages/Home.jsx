import React from "react";

const Home = () => {
  // Example SWOT demo data
  const swotData = [
    { label: "Strengths", value: 80, color: "bg-green-500", description: "Strong athlete physique and mental toughness" },
    { label: "Weaknesses", value: 60, color: "bg-red-500", description: "Needs to improve stamina" },
    { label: "Opportunities", value: 90, color: "bg-blue-500", description: "High potential for sponsorships and partnerships" },
    { label: "Threats", value: 70, color: "bg-yellow-500", description: "Risk of injury during intense training" },
  ];

  return (
    <div className="min-h-screen p-8 bg-gray-50 flex flex-col">
      <h2 className="text-4xl font-semibold mb-8 text-center">SWOT Analysis & Metrics</h2>

      
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-2 xl:grid-cols-2 gap-8">
        {swotData.map((item, index) => (
          <div
            key={index}
            className="bg-white p-8 rounded-lg shadow-lg hover:shadow-xl transition-all duration-300 transform hover:scale-105 flex flex-col justify-between"
            style={{ minHeight: "350px" }}
          >
            
            <div>
              <h3 className="text-2xl font-medium text-gray-700 mb-4">{item.label}</h3>
              <p className="text-lg text-gray-500 mb-6">{item.description}</p>
            </div>

            
            <div className="flex-grow">
              <div className="w-full bg-gray-200 h-2 rounded-full mb-4">
                <div
                  className={`${item.color} h-2 rounded-full`}
                  style={{ width: `${item.value}%` }}
                ></div>
              </div>
              <p className="text-lg text-gray-500">{item.value}%</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Home;
