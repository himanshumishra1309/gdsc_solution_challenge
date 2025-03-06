import React, { useState } from 'react';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';

// Sample news
const newsArticles = [
  {
    title: 'India Clinches T20 Series Against Australia',
    summary: 'India secured a thrilling 3-2 series victory against Australia, with Suryakumar Yadav\'s explosive batting leading the charge in the final match.',
    sport: 'Cricket',
  },
  {
    title: 'Neeraj Chopra Wins Gold at Diamond League',
    summary: 'Olympic champion Neeraj Chopra secured a gold medal in the latest Diamond League event with a stunning 89.67m javelin throw.',
    sport: 'Athletics',
  },
  {
    title: 'Messi Breaks Another Record in MLS',
    summary: 'Lionel Messi became the fastest player to score 20 goals in MLS history, leading Inter Miami to a 3-1 victory over LA Galaxy.',
    sport: 'Football',
  },
  {
    title: 'India Announces Squad for Cricket World Cup',
    summary: 'The BCCI has announced a strong 15-member squad for the upcoming Cricket World Cup, with Rohit Sharma leading the team.',
    sport: 'Cricket',
  },
  {
    title: 'Indian Women\'s Hockey Team Qualifies for Paris Olympics',
    summary: 'The Indian women\'s hockey team secured their place in the Paris 2024 Olympics after a dominant performance in the qualifiers.',
    sport: 'Hockey',
  },
  {
    title: 'PV Sindhu Advances to All England Open Semifinals',
    summary: 'Indian badminton star PV Sindhu stormed into the semifinals of the All England Open after a stunning victory against the world No. 2.',
    sport: 'Badminton',
  },
];

const News = () => {
  const [selectedSport, setSelectedSport] = useState('All');
  
  
  const filteredNews = selectedSport === 'All' 
    ? newsArticles 
    : newsArticles.filter(article => article.sport === selectedSport);

  return (
    <div className="container mx-auto py-8 px-4">
      <h1 className="text-3xl font-bold mb-6 text-center">Latest Sports News</h1>
      
      {/* Dropdown to select sports */}
      <div className="mb-6 flex justify-center">
        <select 
          value={selectedSport} 
          onChange={(e) => setSelectedSport(e.target.value)} 
          className="p-2 border rounded-md bg-white shadow-md"
        >
          <option value="All">All Sports</option>
          <option value="Cricket">Cricket</option>
          <option value="Football">Football</option>
          <option value="Hockey">Hockey</option>
          <option value="Athletics">Athletics</option>
          <option value="Badminton">Badminton</option>
        </select>
      </div>
      
      {/* Display filtered news */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {filteredNews.map((article, index) => (
          <Card key={index} className="hover:shadow-lg transition-shadow duration-300 p-10">
            <CardHeader>
              <CardTitle>{article.title}</CardTitle>
            </CardHeader>
            <CardContent>
              <p>{article.summary}</p>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
};

export default News;
