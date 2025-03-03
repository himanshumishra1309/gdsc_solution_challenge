import React from 'react';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';

const newsArticles = [
  {
    title: 'India Clinches T20 Series Against Australia',
    summary: 'India secured a thrilling 3-2 series victory against Australia, with Suryakumar Yadav\'s explosive batting leading the charge in the final match.',
  },
  {
    title: 'Neeraj Chopra Wins Gold at Diamond League',
    summary: 'Olympic champion Neeraj Chopra secured a gold medal in the latest Diamond League event with a stunning 89.67m javelin throw.',
  },
  {
    title: 'Messi Breaks Another Record in MLS',
    summary: 'Lionel Messi became the fastest player to score 20 goals in MLS history, leading Inter Miami to a 3-1 victory over LA Galaxy.',
  },
  {
    title: 'India Announces Squad for Cricket World Cup',
    summary: 'The BCCI has announced a strong 15-member squad for the upcoming Cricket World Cup, with Rohit Sharma leading the team.',
  },
  {
    title: 'Indian Women\'s Hockey Team Qualifies for Paris Olympics',
    summary: 'The Indian women\'s hockey team secured their place in the Paris 2024 Olympics after a dominant performance in the qualifiers.',
  },
  {
    title: 'PV Sindhu Advances to All England Open Semifinals',
    summary: 'Indian badminton star PV Sindhu stormed into the semifinals of the All England Open after a stunning victory against the world No. 2.',
  },
];

const News = () => {
  return (
    <div className="container mx-auto py-8 px-4">
      <h1 className="text-3xl font-bold mb-6 text-center">Latest Sports News</h1>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {newsArticles.map((article, index) => (
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
