module DisplaysHelper
  def showTank(x,y,width,height,spacing,peripheral)
    tanks=peripheral.tanks
    return_string=""
    tanks.each do |key,value|
      return_string+="drawHorizontalTank(#{x},#{y+(key.to_i-1)*(height+spacing)},#{width},#{height},'#{value["name"]}',#{(value["amount"].to_f/value["capacity"].to_f)})"
    end
    return_string
  end

  def showPower(x,y,width,height,spacing,peripheral)

  end
end
