# encoding: utf-8

class People::DoubletteChecker
  def check
    Person.find_each do |person|
      doublette = person_doublette_finder.find({ first_name: person.first_name,
                                               last_name: person.last_name,
                                               company_name: person.company_name,
                                               zip_code: person.zip_code,
                                               birthday: person.birthday })
      
      next if person == doublette || doublette_already_exists?(person, doublette)

      Person::Doublette.create!(person_1: person, person_2: doublette)
    end
  end

  private

  def person_doublette_finder
    @person_doublette_finder ||= Import::PersonDoubletteFinder.new
  end

  def doublette_already_exists?(person_1, person_2)
    Person::Doublette.where(person_1: person_1, person_2: person_2)
      .or(Person::Doublette.where(person_2: person_1, person_1: person_2)).any?
  end
end
